# require 'securerandom'
#
# module Cluster
#   class CredentialGenerator
#
#     # "Password doesn't meet complexity requirements: length between 8 and 64 characters,
#     # at least 1 each of upper-case character, lower-case character, digit, special character
#     # (!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~) are required"
#
#     def debug(msg)
#       puts msg if $debug
#     end
#
#     def valid?(str)
#       debug "Verify: '#{str}'"
#       return fail_with(:r1) unless str
#       return fail_with(:r2) if str.length < 8 || str.length > 64
#       return fail_with(:r3) if str.scan(/[A-Z]/).length < 1
#       return fail_with(:r4) if str.scan(/[a-z]/).length < 1
#       return fail_with(:r5) if str.scan(/[0-9]/).length < 1
#       return fail_with(:r6) if str.scan(/[\!"#$%&\'\(\)\*\+,-\.\/:;<=>\?@\[\]\\\^_`\{|\}~]/).length < 1
#       true
#     end
#
#     def fail_with(step)
#       debug "Fails: #{step}"
#       return false
#     end
#
#     def generate(l = 16)
#       max = 1024
#       iter = 0
#       v = SecureRandom.base64(l)
#       while !valid?(v) || iter < max
#         v = SecureRandom.base64(l)
#         iter += 1
#       end
#
#       if valid?(v)
#         v
#       else
#         nil
#       end
#     end
#   end
# end