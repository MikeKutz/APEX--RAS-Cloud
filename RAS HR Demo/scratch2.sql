create or REPLACE
package utl_enum
  authid current_user
as
  procedure add_entry( table_name varchar2, enum_name varchar2 );
  procedure drop_value( table_name VARCHAR2, enum_value int );
  function get_name( enum_value int ) return varchar2 deterministic;
end;
/

create or replace
package body utl_enum
as
  procedure add_entry( table_name varchar2, enum_name varchar2 )
  as
  begin
    execute immediate 'insert into ' || table_name || ' (enum_name) values ( :ename )' using enum_name;
  end add_entry;

  procedure drop_value( table_name VARCHAR2, enum_value int )
  as
  begin
    execute IMMEDIATE 'delete ' || table_name || ' where enum_value = :eval' using enum_value;
  end drop_value;

  function get_name( enum_value int ) return varchar2 deterministic
  as
    return_value varchar2(128 byte);
  begin
    if enum_value is null then return null; end if;

    return_value :=
    case mod(enum_value,7)
      when 1 then 'MON'
      when 2 then 'TUE'
      when 3 then 'WED'
      when 4 then 'THU'
      when 5 then 'FRI'
      when 6 then 'SAT'
      when 7 then 'SUN'
      when 0 then 'SUN'
      else '---'
    end;

    return return_value;
  end get_name;
end;
/

grant enum_cbac to package utl_enum;
grant execute on utl_enum to hr;