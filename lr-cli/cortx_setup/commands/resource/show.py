#
# Copyright (c) 2020 Seagate Technology LLC and/or its Affiliates
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
# For any questions about this software or licensing,
# please email opensource@seagate.com or cortx-questions@seagate.com.
#

import json
from ..command import Command
from cortx_setup.commands.common_utils import get_pillar_data


class ResourceShow(Command):

    def parse_resource_file(self, resource_map_path: str):
        file_type, file_path = resource_map_path.split("://")
        if "json" in file_type:
            with open(file_path,"r") as f:
                return json.loads(f.read())
        else:
            raise Exception(f"Unsupported file type {file_type}")
        

    _args = {
        'manefist': {
            'type': str,
            'default': None,
            'optional': True,
            'help': 'discover HW/SW Manifest for all resources'
        },
        'health': {
            'type': str,
            'default': None,
            'optional': True,
            'help': 'Health check for all the resources in the system'
        },
        'resource_type': {
            'type': str,
            'default': None,
            'optional': True,
            'help': 'Resource type for which resource map is to be fetched'
        },
        'resource_state': {
            'type': str,
            'default': None,
            'optional': True,
            'choices': ['OK', 'FAULT', 'DEGRADED'],
            'help': 'The current state of the resources'
        },
    }

    def run(self, **kwargs):

        key = kwargs['resource_type'].split(">")



        if kwargs["health"]:
            resource_map_path = get_pillar_data('provisioner/common_config/resource_map_path')
            
            resource_dict = self.parse_resource_file(resource_map_path)

            self.logger.debug("Health check for all resources in the system")

        else:
            self.logger.debug("discover HW/SW Manifest for all resources")
        self.logger.debug("Done")
