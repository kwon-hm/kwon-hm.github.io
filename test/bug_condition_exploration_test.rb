#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler'
require 'minitest/autorun'

# Bug Condition Exploration Test for ActiveSupport Security Vulnerability
# **Validates: Requirements 1.1, 1.2, 1.3**
#
# CRITICAL: This test MUST FAIL on unfixed code - failure confirms the bug exists
# DO NOT attempt to fix the test or the code when it fails
# NOTE: This test encodes the expected behavior - it will validate the fix when it passes after implementation
# GOAL: Surface counterexamples that demonstrate the bug exists
#
# Property 1: Bug Condition - 보안 패치 버전 강제
# For any Gemfile 설정에서 activesupport 버전 제약이 `~> 8.0.4.1`로 설정되어 있을 때,
# bundle install 또는 bundle update 실행 시 시스템은 8.0.4.1 이상 8.1.0 미만의
# 보안 패치가 적용된 버전만 설치해야 하며, 8.0.4.1 미만의 취약한 버전은 설치되지 않아야 합니다.

class BugConditionExplorationTest < Minitest::Test
  SECURE_VERSION_MIN = Gem::Version.new('8.0.4.1')
  SECURE_VERSION_MAX = Gem::Version.new('8.1.0')
  VULNERABLE_VERSION = Gem::Version.new('8.0.3')

  def setup
    @gemfile_path = File.expand_path('../Gemfile', __dir__)
    @gemfile_lock_path = File.expand_path('../Gemfile.lock', __dir__)
  end

  # Test Case 1: Verify Gemfile has loose constraint (bug condition)
  def test_gemfile_has_loose_constraint
    gemfile_content = File.read(@gemfile_path)
    
    # Check that activesupport constraint is present
    assert_match(/gem\s+"activesupport"/, gemfile_content,
                 "Gemfile should contain activesupport dependency")
    
    # Extract the constraint
    constraint_line = gemfile_content.lines.find { |line| line.match?(/gem\s+"activesupport"/) }
    
    # Bug condition: constraint is ">= 6.1.7.3" (too loose)
    # This allows vulnerable versions < 8.0.4.1
    if constraint_line.match?(/>=\s*6\.1\.7\.3/)
      puts "\n[COUNTEREXAMPLE] Gemfile has loose constraint: #{constraint_line.strip}"
      puts "This allows vulnerable versions < 8.0.4.1 to be installed"
    end
    
    # Expected behavior after fix: constraint should be "~> 8.0.4.1"
    # This test will FAIL on unfixed code (expected)
    assert_match(/~>\s*8\.0\.4\.1/, constraint_line,
                 "Gemfile should have pessimistic constraint '~> 8.0.4.1' to enforce secure versions")
  end

  # Test Case 2: Verify installed version is vulnerable (bug condition)
  def test_installed_version_is_vulnerable
    # Get installed activesupport version from Bundler
    spec = Bundler.load.specs.find { |s| s.name == 'activesupport' }
    
    assert spec, "activesupport should be installed"
    
    installed_version = spec.version
    puts "\n[INFO] Currently installed activesupport version: #{installed_version}"
    
    # Check if installed version is vulnerable
    if installed_version < SECURE_VERSION_MIN
      puts "[COUNTEREXAMPLE] Installed version #{installed_version} is vulnerable (< 8.0.4.1)"
      puts "This confirms the bug exists: loose constraint allows vulnerable versions"
    end
    
    # Expected behavior after fix: version should be >= 8.0.4.1 and < 8.1.0
    # This test will FAIL on unfixed code (expected)
    assert installed_version >= SECURE_VERSION_MIN,
           "Installed activesupport version should be >= 8.0.4.1 (secure), but got #{installed_version}"
    assert installed_version < SECURE_VERSION_MAX,
           "Installed activesupport version should be < 8.1.0 (pessimistic constraint), but got #{installed_version}"
  end

  # Test Case 3: Verify Gemfile.lock contains vulnerable version (bug condition)
  def test_gemfile_lock_contains_vulnerable_version
    gemfile_lock_content = File.read(@gemfile_lock_path)
    
    # Extract activesupport version from Gemfile.lock
    version_line = gemfile_lock_content.lines.find { |line| line.match?(/^\s+activesupport\s+\(/) }
    
    assert version_line, "Gemfile.lock should contain activesupport entry"
    
    # Parse version from line like "    activesupport (8.0.3)"
    version_match = version_line.match(/activesupport\s+\(([^)]+)\)/)
    assert version_match, "Should be able to parse activesupport version from Gemfile.lock"
    
    locked_version = Gem::Version.new(version_match[1])
    puts "\n[INFO] Gemfile.lock has activesupport version: #{locked_version}"
    
    # Check if locked version is vulnerable
    if locked_version < SECURE_VERSION_MIN
      puts "[COUNTEREXAMPLE] Gemfile.lock contains vulnerable version #{locked_version} (< 8.0.4.1)"
      puts "Expected: version >= 8.0.4.1 and < 8.1.0"
    end
    
    # Expected behavior after fix: locked version should be >= 8.0.4.1 and < 8.1.0
    # This test will FAIL on unfixed code (expected)
    assert locked_version >= SECURE_VERSION_MIN,
           "Gemfile.lock should have activesupport >= 8.0.4.1 (secure), but got #{locked_version}"
    assert locked_version < SECURE_VERSION_MAX,
           "Gemfile.lock should have activesupport < 8.1.0 (pessimistic constraint), but got #{locked_version}"
  end

  # Test Case 4: Verify constraint allows vulnerable versions (bug condition)
  def test_constraint_allows_vulnerable_versions
    gemfile_content = File.read(@gemfile_path)
    constraint_line = gemfile_content.lines.find { |line| line.match?(/gem\s+"activesupport"/) }
    
    # Extract constraint pattern
    if constraint_line.match?(/>=\s*6\.1\.7\.3/)
      # Bug condition: ">= 6.1.7.3" allows any version >= 6.1.7.3
      # This includes vulnerable versions like 8.0.0, 8.0.1, 8.0.2, 8.0.3
      puts "\n[COUNTEREXAMPLE] Constraint '>= 6.1.7.3' allows vulnerable versions:"
      puts "  - Allows: 8.0.0, 8.0.1, 8.0.2, 8.0.3 (all vulnerable)"
      puts "  - Should only allow: >= 8.0.4.1 and < 8.1.0"
      
      # This demonstrates the root cause: loose constraint
      vulnerable_versions = ['8.0.0', '8.0.1', '8.0.2', '8.0.3']
      vulnerable_versions.each do |v|
        version = Gem::Version.new(v)
        if version >= Gem::Version.new('6.1.7.3')
          puts "  - Version #{v} is allowed by '>= 6.1.7.3' but is vulnerable"
        end
      end
    end
    
    # Expected behavior after fix: constraint should be "~> 8.0.4.1"
    # which only allows >= 8.0.4.1 and < 8.1.0
    # This test will FAIL on unfixed code (expected)
    refute constraint_line.match?(/>=\s*6\.1\.7\.3/),
           "Constraint should not be '>= 6.1.7.3' as it allows vulnerable versions"
    assert constraint_line.match?(/~>\s*8\.0\.4\.1/),
           "Constraint should be '~> 8.0.4.1' to enforce secure versions only"
  end
end
