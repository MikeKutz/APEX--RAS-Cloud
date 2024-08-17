begin
  sys.xs_data_security.remove_OBJECT_POLICY(
    policy => 'status_policy', 
    schema => 'hr',
    object =>'test_col'
    );
end;
/
begin
  sys.xs_data_security.remove_OBJECT_POLICY(
    policy => 'status_ro_policy', 
    schema => 'hr',
    object =>'test_col'
    );
end;
/
begin
  sys.xs_data_security.remove_OBJECT_POLICY(
    policy => 'status_rw1_policy', 
    schema => 'hr',
    object =>'test_col'
    );
end;
/
begin
  sys.xs_data_security.remove_OBJECT_POLICY(
    policy => 'status_rw2_policy', 
    schema => 'hr',
    object =>'test_col'
    );
end;
/
begin
  sys.xs_data_security.remove_OBJECT_POLICY(
    policy => 'status_rw_policy', 
    schema => 'hr',
    object =>'test_col'
    );
end;
/

BEGIN
  sys.xs_data_security.delete_policy(
    policy                   => 'status_policy' );
end;
/
BEGIN
  sys.xs_data_security.delete_policy(
    policy                   => 'status_ro_policy' );
end;
/
begin
  sys.xs_data_security.delete_policy(
    policy                   => 'status_rw_policy' );
end;
/
begin
  sys.xs_data_security.delete_policy(
    policy                   => 'status_rw1_policy' );
end;
/
begin
  sys.xs_data_security.delete_policy(
    policy                   => 'status_rw2_policy' );
end;
/
