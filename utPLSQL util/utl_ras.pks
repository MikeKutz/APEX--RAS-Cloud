create or replace
package utl_ras
  authid current_user
as
  /* package for utPLSQL to incorporate RAS
  *  Real Application Security (RAS)
  *
  * username:dbh is the parameter from tag
  * dbh is optional
  *
  * @headcom
  */
  
  /* creates and records a RAS session for user `username`
  *
  * @param userame user for RAS Session
  * @throws  no_data_found  username is null
  */
  procedure create_session_for_user( username in varchar2
                                    ,is_external boolean default false );

  /* destroys a RAS Session
   * and remove from memory (user_sessions)
   *
   * @param  username  username:dbh
   */
  procedure terminate_session( username in varchar2 );
  
  /* remove session info from memory
   * assumes RAS Session has already been destroyed
   *
   * @param  username  username:dbh
   */
  procedure remove_session_id( username in varchar2 );
  
  /* destroys all know RAS Sessions
   * and clears info
   *
   */
  procedure terminate_all_sessions;
  
  /* return's saved sessionID for user
   * 
   *
   * @param   username  username:dbh
   * @throws            data_not_found if not recorded
   */
  function get_session_id( username in varchar2) return raw;
  
  /* attaches current DB Session to a RAS Session
   * Creates a RAS Session if one is not known
   *
   * @param  username    username:dbh_id
   * @param  is_external identifies username as internal or external
   */
  procedure attach_session( username in varchar2
                            ,is_external boolean default false );

  
  /* simple end of RAS Session */
  procedure detach_session;
  
  /* Ensure that the current DB Session is not attached to a RAS Session */
  procedure assert_not_attached;
  
  /* checks to see if DB Session is currently attached to a RAS Session
  *
  * @return TRUE if session is a RAS session
  */
  function is_attached return boolean;
  
  /* ends current session (causes rollback) */
  procedure abort_session;

end;
/
