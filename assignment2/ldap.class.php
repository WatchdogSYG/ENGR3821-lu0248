<?php
//author:Brandon Lu 10/06/19
//https://xref.dokuwiki.org/reference/dokuwiki/nav.html?inc/auth/basic.class.php.html
class ldapAuth extends auth/basic.class.php {
	//contructor
	//set this->$cando capabillities
	//set this->success = true||false
	ldapAuth(){
		this->$cando=(0,0,0,0,0,0,0,0,0,0,0);
		this->success=true;
	}

	//Returns info about the given user needs to contain at least these fields:
	//name string full name of the user
	//mail string email addres of the user
	//grps array list of groups the user is in
	getUserData($user){
		$result = $ldap->search(
   			'(objectclass=*)',
   			"ou=People,$user",
   			Zend\Ldap\Ldap::SEARCH_SCOPE_SUB
		);

		$userData=
		foreach ($result as $item){

		}
	}


	//checks pass and returns bool
	checkPass($user,$pass){
		return false;
	}
}
?>