# -*- encoding: utf-8 -*-
# stub: ffi 1.15.4.pre1 ruby lib
# stub: ext/ffi_c/extconf.rb

Gem::Specification.new do |s|
  s.name = "ffi".freeze
  s.version = "1.15.4.pre1"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/ffi/ffi/issues", "changelog_uri" => "https://github.com/ffi/ffi/blob/master/CHANGELOG.md", "documentation_uri" => "https://github.com/ffi/ffi/wiki", "mailing_list_uri" => "http://groups.google.com/group/ruby-ffi", "source_code_uri" => "https://github.com/ffi/ffi/", "wiki_uri" => "https://github.com/ffi/ffi/wiki" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Wayne Meissner".freeze]
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIC/DCCAeSgAwIBAgIBAjANBgkqhkiG9w0BAQsFADAkMSIwIAYDVQQDDBl0cmF2\naXMtY2kvREM9ZHVtbXkvREM9b3JnMB4XDTIxMDUyMjA3MjgxNFoXDTIyMDUyMjA3\nMjgxNFowJDEiMCAGA1UEAwwZdHJhdmlzLWNpL0RDPWR1bW15L0RDPW9yZzCCASIw\nDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAK+5uh+zqCXKho0zXIaLmJD6YDpa\nl07nJ+PQFcMBYgsKA2ip01THj3DVYwP/va6hYgqPmxEJB3tsEthKnHVHm0dgqqg/\ngfyDFU0ZfbSYKeNlZQRIdddKPc6dNbmtY2gBWFt6YOZnBccsgJmSUAbh0a9xhVbm\nqAStn/q7eq9iW9+12AB9HM+QCWrsCAXEHGGNENDAK9HtHwBs4KsneiIQY5rd/Mzs\nIi25XXnDUa1NjC4u/mMuJXBpWLw2rEAQkzEFQBZR0W0ehm9Mi4TokhLy/QH8GRaH\n0KADzpk1cxuOrEBIhy6ISQs7g/tI6YTePAmDMTsodov02FZCcMpoxOifpFkCAwEA\nAaM5MDcwCQYDVR0TBAIwADALBgNVHQ8EBAMCBLAwHQYDVR0OBBYEFOTn5ek+QtcI\ng+ZglIvRPAPGoXvLMA0GCSqGSIb3DQEBCwUAA4IBAQCkYZdWhRDXD2i1x+i9ldUt\nseNbE+9n742DLgTeQoGyrGO8qabcfM/DBC5iohpFfXa6tJ/ufT2G4xwJq9CVgkY9\nJQWZfxrqzRwY69Rq7MA5lAJ9/HpzkjEiZjPO0jYEhy7iznnhWCzmUFFO9++hH5Mj\nSviDbWEcg72gtdu53KTk+dlWFRMK/zVXX2LsxdJ8+oL/HrPUKIPaMuvaPiOxZ85i\n6k/UaTHptue0Rj8i8Xv3VmPvYrk3LacY/rmUvJAv+rrd5vBxYI8HZ+VPZD+IcLVL\nbF2Y4mTGMgJ2+MB9E838+Rh6U7sDsKfP5d9102VfpDaueM4jxBHxeY7g/UIyYS/1\n-----END CERTIFICATE-----\n".freeze]
  s.date = "2021-07-09"
  s.description = "Ruby FFI library".freeze
  s.email = "wmeissner@gmail.com".freeze
  s.extensions = ["ext/ffi_c/extconf.rb".freeze]
  s.files = ["ext/ffi_c/extconf.rb".freeze]
  s.homepage = "https://github.com/ffi/ffi/wiki".freeze
  s.licenses = ["BSD-3-Clause".freeze]
  s.rdoc_options = ["--exclude=ext/ffi_c/.*\\.o$".freeze, "--exclude=ffi_c\\.(bundle|so)$".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3".freeze)
  s.rubygems_version = "3.4.10".freeze
  s.summary = "Ruby FFI".freeze

  s.installed_by_version = "3.4.10" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
  s.add_development_dependency(%q<rake-compiler>.freeze, ["~> 1.0"])
  s.add_development_dependency(%q<rake-compiler-dock>.freeze, ["~> 1.0"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 2.14.1"])
  s.add_development_dependency(%q<rubygems-tasks>.freeze, ["~> 0.2.4"])
end
