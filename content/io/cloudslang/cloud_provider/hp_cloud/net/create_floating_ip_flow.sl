#   (c) Copyright 2015 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
# Main flow to call to obtain a floating IP 
#
# Inputs:
#   - token - auth token obtained by get_authenication_flow
#   - region - HP Cloud region; 'a' or 'b'  (US West or US East) 
#   - proxy_host - optional - proxy server used to access the web site - Default: none
#   - proxy_port - optional - proxy server port - Default: none
# Outputs:
#   - ip_addres - IP address created
#   - return_result - response of the operation
#   - status_code - normal status code is 202
# Results:
#   - SUCCESS - operation succeeded
#   - FAILURE - otherwise
####################################################

namespace: io.cloudslang.cloud_provider.hp_cloud.net

imports:
  utils: io.cloudslang.cloud_provider.hp_cloud.utils
  print: io.cloudslang.base.print
  json: io.cloudslang.base.json
  
flow:
  name: create_floating_ip_flow
  inputs:
    - token
    - region
    - proxy_host:
        required: false
    - proxy_port:
        required: false
  workflow:
    - list_networks:
        do:
          list_all_networks:
            - token
            - region
            - proxy_host
            - proxy_port
        publish:
          - return_result
          - status_code

    - get_external_id:
        do:
          utils.get_external_net_id:
            - json_network_list: return_result
        publish:
          - ext_network_id

    - allocate_floating_ip:
        do:
          create_floating_ip:
            - ext_network_id
            - token
            - region
            - proxy_host
            - proxy_port          
        publish:
          - return_result
          - status_code

    - get_ip_result:
        do:
          json.get_value_from_json:
            - json_input: return_result
            - key_list: ["'floatingip'", "'floating_ip_address'"]
        publish:
          - ip_address: value

    - on_failure:
      - ip_error:
          do:
            print.print_text:
              - text: "'! ERROR ALLOCATING IP (' + status_code + ') : ' + return_result" 

  outputs:
    - return_result
    - status_code
    - ip_address