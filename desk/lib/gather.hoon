/-  *gather, res-sur=resource
|%
::
::
::
:: Remove a single ship from a list
++  remove-our
  |=  [ship=@p import=(list @p)]
  ^-  (list @p)
  (skip `(list @p)`import |=(a=@p =(a ship)))
::
::
:: Remove Banned ships from a list
++  remove-banned
  |=  [import=(list @p) banned=(set @p)]
  ^-  (list @p)
  =/  import=(set @p)  `(set @p)`(silt import)
  ~(tap in (~(dif in import) banned))
::
::
:: Remove duplicate ships from a list
++  remove-dupes
  |=  import=(list @p)
  =|  export=(list @p)
  =/  sorted=(list @p)  (sort `(list @p)`import lth)
  |-  ^-  (list @p)
  ?~  sorted  export
  =/  indexes=(list @)  (fand ~[i.sorted] sorted)
  ?:  (gth (lent indexes) 1)
    $(sorted (oust [-:indexes 1] `(list @p)`sorted))
  $(export (weld export `(list @p)`~[i.sorted]), sorted t.sorted) 
::
::
:: Coerce resource and members into $collection structure for
:: the $collections map
++  make-collection-values
  |=  groups=(map resource:res-sur members)
  =|  export=(list collection)
  =/  keys=(list resource:res-sur)  ~(tap in ~(key by groups))
  |-  ^-  (list collection)
  ?~  keys  
     export
  =/  gang=members  (~(got by groups) i.keys)
  %=  $
     export  ;:  welp  export
                :~  :*
                       `@t`->:keys 
                        gang
                        %.n
                        `i.keys
             ==  ==  ==
     keys  t.keys
  ==
::
::
:: Pull a $collection id from a group $resource
++  single-group-id
  |=  [r=resource collections=(map id collection)]
  =|  export=id
  =/  ids=(list id)  ~(tap in ~(key by collections))
  |-  ^-  id
  ?~  ids  export
  ?.  =(r resource:(~(got by collections) i.ids))
    $(ids t.ids)
  $(export i.ids, ids t.ids) 
::
::
:: Pull $collection ids that have a group $resource
++  get-group-ids
  |=  collections=(map id collection) 
  =|  group-ids=(list id)
  =/  ids=(list id)  ~(tap in ~(key by collections))
  |-  ^-  (list id)
  ?~  ids  group-ids
  ?:  =(~ resource:(~(got by collections) i.ids))
     $(ids t.ids)
  $(group-ids (weld group-ids `(list id)`~[i.ids]), ids t.ids)
::
::
:: Constructs the $receive-ships map for invites :: TODO probably can be faster using combo of ++turn and somehow pinning the [%pending] as value
++  make-receive-ships-map
  |=  send-to=(list @p)
  ^-  (map @p =ship-invite)
  =|  receive-ships=(map @p =ship-invite)
  |-
  ?~  send-to  receive-ships
  $(receive-ships (~(put by receive-ships) i.send-to *ship-invite), send-to t.send-to)
::
::
:: Get a list of ids we've accepted
++  get-accepted-ids
  |=  [our=@p invites=invites ids=(list id)]
  =|  accepted-ids=(list id)
  |-  ^-  (list id)
  ?~  ids  accepted-ids
  =+  inv=(need (~(get by invites) i.ids)) 
  ?.  =(%accepted +1:(need (~(get by receive-ships.inv) our)))
     $(ids t.ids)  
  %=  $ 
    accepted-ids  (weld accepted-ids ~[i.ids])
    ids           t.ids
  ==
::
::
:: Makes list of all invite ids for a ship when our.bol = 
:: init-ship and the ship in question is in the corresponding
:: $receive-ships map.
++  id-comb
  |=  [init=@p menace=@p invites=invites]
  =/  ids=(list id)  ~(tap in ~(key by invites))
  =|  export=(list id)
  |-  ^-  (list id)
  ?~  ids  export
  =+  dets=(need (~(get by invites) i.ids))
  ?.  ?&  =(init init-ship:dets)
          (~(has by receive-ships.dets) menace) 
      ==
    $(ids t.ids)
  $(export (weld export `(list id)`~[i.ids]), ids t.ids)
--

