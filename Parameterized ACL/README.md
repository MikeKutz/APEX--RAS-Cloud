Parameterized ACLs
===

Namespaces allow you to assign an Attribute value on a per User basis.  Parameterized ACLs allow you to assign an Attribute value on a per ACL basis.

Parameterized ACLs are the clear choice when you are dealing with 1 Domain and each ACL has a unique value.

ACLs can be tagged with key-value pairs.  From there, the Domain can be defined with a placeholder ( `&key` ) for the Domain. (eg of `deptartment_id = &dept_id` )

ACL `it_acl` has attribute `dept_id` with a value of `60` while `hr_representitive` has `dept_id` of `40`.  Addiditonally, the Domain `'yes'=&view_sal` is used with only the ACL `hr_representive` having the parameter `view_sal` set to `yes`.  In this scenario, the parameter values that were once defined in a Namespace are now defined in the ACL.

# Setup
For this example, no Namespace will be involved.  The employee ACL will be configured the same as the original HR Demo while the `it_department` and `hr_representive` will be configured with parameters.

Unlike the other examples, the Policy is defined first.  This way, parameters can be defined for the Policy and then for the Policy-ACL combo.

The 3rd script ( `03-hr_adjust_parameters` ) demonstrates how to update the parameter value for an ACL.


