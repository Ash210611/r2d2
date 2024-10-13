## Updating the Proxy Images

In order to update the proxy images:

- Run the lambda in nonprod called 'ImageAlert' with test event called AlertNoEmail
- In the output, it should print each region with the new image id that it needs
- copy that block, and paste it into the /ansible/vars/envmapping.yaml, in the hardened image section

## TODO

- Rename the ImageAlert lambda to something including proxy, probably ProxyImageAlert
- Make the printout consistent, so even if the images are not updated, the 