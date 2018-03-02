next steps:

DONT reset controller node (saturn] it's ssh keys are hardcoded in here

1. setup database / debug orginal spaghetticode
    >> Continue here: there is some bug while saving the model.
    coucdbkit should be updated or best be replaced completly..
    >> Continue here: json.data.imgdata.COMPOSTIE_PIXEL_IMAGE[!!!!!]
    there is for some reson s key there innsead of the nummer 0001, check the database.



2. setup celery
3. setup worker
4. mount persitend drive in /srv (make sure the data stays!!)
5. backups




meta: changes todo about the installer:
- change server machine scripts to use 'userdata' as in the openstack machine setup scripts (ssh keys)!



notes:

> ./create_tunnel.sh 172.23.46.135
