This Puppet module provides a new face, "undo", which will parse an arbitrary yaml report for changed resources and generate and apply a new catalog for the node which reverses those changes. It's intended to be run on the agent in question.

Example:
`puppet undo report /opt/puppetlabs/puppet/cache/state/last_run_report.yaml`

Todo:
1: Add support for files utilizing local filebucket
2: Add noop option
3: Add option to write the catalog instead of applying it
4: Add option to export puppet code instead of a catalog
5: After https://tickets.puppetlabs.com/browse/MODULES-2192 is resolved, add support for file_line resources to utilize filebucket
