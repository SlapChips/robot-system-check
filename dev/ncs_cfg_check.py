import ncs

"""
Example code to set values and get vaues in NSO.
User 'ncsadmin' must be in the ncsadmin group, so check the nacm rules.
"""
with ncs.maapi.single_write_trans('ncsadmin', 'cli') as t:
    t.set_elem2('Kilroy was here', '/ncs:devices/authgroups/group{default}/default-map/remote-name')
    t.apply()

with ncs.maapi.single_read_trans('ncsadmin', 'cli') as t:
    desc = t.get_elem('/ncs:devices/authgroups/group{default}/default-map/remote-name')
    print("Description for device ce0 = %s" % desc)


"""
Example code to set variables and return dry-run
"""
with ncs.maapi.single_write_trans('ncsadmin', 'cli') as t:
    t.set_elem2('NewText', '/ncs:devices/authgroups/group{default}/default-map/remote-name')
    # t.apply()
    cp = ncs.maapi.CommitParams()
    cp.dry_run_xml()
    r = t.apply_params(True, cp)
    print(r)
