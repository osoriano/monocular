#
# WARNING: Expects to be run in the pf9-deploy directory
#

from constants import get_rds_defaults


print get_rds_defaults()['engine_version']['default']
