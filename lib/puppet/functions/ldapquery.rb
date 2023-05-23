# frozen_string_literal: true

# @summary DEPRECATED.  Use the namespaced function [`ldapquery::query`](#ldapqueryquery) instead.
Puppet::Functions.create_function(:ldapquery) do
  dispatch :deprecation_gen do
    repeated_param 'Any', :args
  end
  def deprecation_gen(*args)
    call_function('deprecation', 'ldapquery', 'This function is deprecated, please use ldapquery::query instead.')
    call_function('ldapquery::query', *args)
  end
end
