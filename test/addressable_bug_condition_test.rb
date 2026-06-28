#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler'
require 'minitest/autorun'

# Bug Condition Exploration Test for Addressable ReDoS Vulnerability
# **Validates: Requirements 1.1, 1.2, 1.3, 2.1, 2.2, 2.3**
#
# CRITICAL: This test MUST FAIL on unfixed code - failure confirms the bug exists
# DO NOT attempt to fix the test or the code when it fails
# NOTE: This test encodes the expected behavior - it will validate the fix when it passes after implementation
# GOAL: Surface counterexamples that demonstrate the loose constraint bug exists
#
# Property 1: Bug Condition - Version Constraint Restricts to Secure Range
# For any Gemfile where the addressable gem constraint is changed to `~> 2.8.7`,
# the dependency resolution system SHALL restrict addressable versions to >= 2.8.7 and < 2.9.0,
# preventing both downgrades to vulnerable versions and automatic upgrades to potentially breaking major versions.

class AddressableBugConditionTest < Minitest::Test
  SECURE_VERSION_MIN = Gem::Version.new('2.8.7')
  SECURE_VERSION_MAX = Gem::Version.new('2.9.0')
  VULNERABLE_VERSION = Gem::Version.new('2.8.0')

  def setup
    @gemfile_path = File.expand_path('../Gemfile', __dir__)
    @gemfile_lock_path = File.expand_path('../Gemfile.lock', __dir__)
  end

  # Test Case 1: Verify Gemfile uses >= operator (bug condition)
  def test_gemfile_uses_loose_operator
    gemfile_content = File.read(@gemfile_path)
    
    # Check that addressable constraint is present
    assert_match(/gem\s+"addressable"/, gemfile_content,
                 "Gemfile should contain addressable dependency")
    
    # Extract the constraint line
    constraint_line = gemfile_content.lines.find { |line| line.match?(/gem\s+"addressable"/) }
    
    # Bug condition: constraint uses ">=" operator (too loose)
    if constraint_line.match?(/>=\s*2\.8\.0/)
      puts "\n[COUNTEREXAMPLE] Gemfile uses loose '>=' operator: #{constraint_line.strip}"
      puts "This allows downgrades to vulnerable versions and upgrades to breaking versions"
    end
    
    # Expected behavior after fix: constraint should use "~>" operator
    # This test will FAIL on unfixed code (expected)
    assert_match(/~>\s*2\.8\.7/, constraint_line,
                 "Gemfile should have pessimistic constraint '~> 2.8.7' to restrict to secure range")
  end

  # Test Case 2: Verify constraint version is 2.8.0 not 2.8.7 (bug condition)
  def test_constraint_version_is_not_secure
    gemfile_content = File.read(@gemfile_path)
    constraint_line = gemfile_content.lines.find { |line| line.match?(/gem\s+"addressable"/) }
    
    # Bug condition: constraint specifies 2.8.0 instead of 2.8.7
    if constraint_line.match?(/2\.8\.0/)
      puts "\n[COUNTEREXAMPLE] Gemfile specifies version 2.8.0 instead of secure 2.8.7"
      puts "Current: #{constraint_line.strip}"
      puts "Expected: gem \"addressable\", \"~> 2.8.7\""
    end
    
    # Expected behavior after fix: constraint should specify 2.8.7
    # This test will FAIL on unfixed code (expected)
    assert_match(/2\.8\.7/, constraint_line,
                 "Gemfile should specify version 2.8.7 (secure minimum), not 2.8.0")
  end

  # Test Case 3: Verify constraint is NOT pessimistic (bug condition)
  def test_constraint_lacks_pessimistic_operator
    gemfile_content = File.read(@gemfile_path)
    constraint_line = gemfile_content.lines.find { |line| line.match?(/gem\s+"addressable"/) }
    
    # Bug condition: constraint does NOT use pessimistic operator "~>"
    unless constraint_line.match?(/~>/)
      puts "\n[COUNTEREXAMPLE] Gemfile lacks pessimistic operator '~>'"
      puts "Current: #{constraint_line.strip}"
      puts "This allows unrestricted version upgrades including breaking changes"
    end
    
    # Expected behavior after fix: constraint should use "~>" operator
    # This test will FAIL on unfixed code (expected)
    assert_match(/~>/, constraint_line,
                 "Gemfile should use pessimistic operator '~>' to prevent breaking version changes")
  end

  # Test Case 4: Verify constraint allows vulnerable versions < 2.8.7 (bug condition)
  def test_constraint_allows_vulnerable_versions
    gemfile_content = File.read(@gemfile_path)
    constraint_line = gemfile_content.lines.find { |line| line.match?(/gem\s+"addressable"/) }
    
    # Bug condition: ">= 2.8.0" allows versions < 2.8.7 (vulnerable)
    if constraint_line.match?(/>=\s*2\.8\.0/)
      puts "\n[COUNTEREXAMPLE] Constraint '>= 2.8.0' allows vulnerable versions:"
      
      # Demonstrate vulnerable versions that are allowed
      vulnerable_versions = ['2.8.0', '2.8.1', '2.8.2', '2.8.3', '2.8.4', '2.8.5', '2.8.6']
      vulnerable_versions.each do |v|
        version = Gem::Version.new(v)
        if version >= VULNERABLE_VERSION && version < SECURE_VERSION_MIN
          puts "  - Version #{v} is allowed by '>= 2.8.0' but is vulnerable (< 2.8.7)"
        end
      end
      
      puts "Expected: Only versions >= 2.8.7 and < 2.9.0 should be allowed"
    end
    
    # Expected behavior after fix: constraint should prevent versions < 2.8.7
    # This test will FAIL on unfixed code (expected)
    refute constraint_line.match?(/>=\s*2\.8\.0/),
           "Constraint should not be '>= 2.8.0' as it allows vulnerable versions < 2.8.7"
  end

  # Test Case 5: Verify constraint allows breaking versions >= 2.9.0 (bug condition)
  def test_constraint_allows_breaking_versions
    gemfile_content = File.read(@gemfile_path)
    constraint_line = gemfile_content.lines.find { |line| line.match?(/gem\s+"addressable"/) }
    
    # Bug condition: ">= 2.8.0" has no upper bound, allows >= 2.9.0 (breaking changes)
    if constraint_line.match?(/>=\s*2\.8\.0/)
      puts "\n[COUNTEREXAMPLE] Constraint '>= 2.8.0' has no upper bound:"
      puts "  - Allows: 2.9.0, 2.10.0, 3.0.0, etc. (potential breaking changes)"
      puts "  - Expected: Only versions >= 2.8.7 and < 2.9.0 should be allowed"
      puts "  - Pessimistic constraint '~> 2.8.7' would prevent automatic upgrades to 2.9.0+"
    end
    
    # Expected behavior after fix: constraint should prevent versions >= 2.9.0
    # This test will FAIL on unfixed code (expected)
    assert_match(/~>\s*2\.8\.7/, constraint_line,
                 "Constraint should be '~> 2.8.7' to prevent automatic upgrades to 2.9.0+")
  end

  # Test Case 6: Verify constraint mathematically allows insecure range (bug condition)
  def test_constraint_mathematical_range_is_insecure
    gemfile_content = File.read(@gemfile_path)
    constraint_line = gemfile_content.lines.find { |line| line.match?(/gem\s+"addressable"/) }
    
    # Parse the constraint
    if constraint_line.match?(/>=\s*2\.8\.0/)
      # Bug condition: mathematical range is [2.8.0, ∞)
      # This includes vulnerable range [2.8.0, 2.8.7) and breaking range [2.9.0, ∞)
      puts "\n[COUNTEREXAMPLE] Mathematical range analysis:"
      puts "  Current constraint: '>= 2.8.0'"
      puts "  Allowed range: [2.8.0, ∞)"
      puts "  Vulnerable range: [2.8.0, 2.8.7) - INCLUDED (BAD)"
      puts "  Secure range: [2.8.7, 2.9.0) - INCLUDED (GOOD)"
      puts "  Breaking range: [2.9.0, ∞) - INCLUDED (BAD)"
      puts ""
      puts "  Expected constraint: '~> 2.8.7'"
      puts "  Expected range: [2.8.7, 2.9.0)"
      puts "  Vulnerable range: [2.8.0, 2.8.7) - EXCLUDED (GOOD)"
      puts "  Secure range: [2.8.7, 2.9.0) - INCLUDED (GOOD)"
      puts "  Breaking range: [2.9.0, ∞) - EXCLUDED (GOOD)"
    end
    
    # Expected behavior after fix: mathematical range should be [2.8.7, 2.9.0)
    # This test will FAIL on unfixed code (expected)
    assert_match(/~>\s*2\.8\.7/, constraint_line,
                 "Constraint should be '~> 2.8.7' to restrict range to [2.8.7, 2.9.0)")
  end
end
