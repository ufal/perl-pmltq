<?xml version="1.0" encoding="utf-8"?>

<tree_query xmlns="http://ufal.mff.cuni.cz/pdt/pml/">
 <head>
  <schema href="tree_query_schema.xml" />
 </head>
 <q-trees>
  <LM id="q-08-12-01_215956">
   <q-nodes>
    <node>
     <node-type>t-node</node-type>
     <q-children>
      <test operator="=">
       <a>functor</a>
       <b>"DPHR"</b>
      </test>
     </q-children>
    </node>
   </q-nodes>
  </LM>
  <LM id="q-08-12-02_145647">
   <q-nodes>
    <node>
     <node-type>t-node</node-type>
     <q-children>
      <node>
       <node-type>t-node</node-type>
       <relation>
        <child />
       </relation>
      </node>
      <test operator="=">
       <a>functor</a>
       <b>"DPHR"</b>
      </test>
     </q-children>
    </node>
   </q-nodes>
  </LM>
  <LM id="q-08-12-02_161611">
   <q-nodes>
    <node>
     <node-type>t-node</node-type>
     <q-children>
      <node>
       <node-type>t-node</node-type>
       <relation>
        <child />
       </relation>
      </node>
      <or>
       <test operator="=">
        <a>functor</a>
        <b>"DPHR"</b>
       </test>
       <test operator="=">
        <a>functor</a>
        <b>"CPHR"</b>
       </test>
      </or>
     </q-children>
    </node>
   </q-nodes>
  </LM>
 </q-trees>
</tree_query>
