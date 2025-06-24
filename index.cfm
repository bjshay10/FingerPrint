<cfapplication name="FingerPrint" sessionmanagement="yes" sessiontimeout="#CreateTimeSpan(0,0,60,0)#">

<!--- Finger Print Information Tracking Page 
		Created By: B.J. Shay
		On: 03/25/2011
		Purpose: to Replace current method of Finger Print tracking (excel spreadsheet)
		Modification 
		06/17/11 - BJS - Added "Undetermined" Y/N radio buttons to the form. 
						Fixed the Search to search for everyone correctly
		10/20/11 - BJS - Added "Disconnected" check box to the form 
						 Changed where Attachments are saved so Rachel could access
						 the files.
		12/09/11 - BJS - Added Report: Needs Active only report (only people with disconnected not checked)
		01/18/12 - BJS - Added the disconnected flag to the search results
		12/03/14 - BJS - Added check box for Student Teachers
					   - Added Student Teacher to Report/export drop down
		01/21/16 - BJS - Added checkboxes for JRE, MCVS, and IA	
		10/07/19 - BJS - Added check box for Student Teacher (FP with CDE) add	(FP with D51)
        03/18/25 - BJS - Adding Ability to Delete Files	 
		--->
        
        
<!--- StepNum list
		StepNum = 0 - not logged in
		StepNum = 1 - logged in make selection to enter new or query existing
		StepNum = 10 - Enter New
		StepNum = 20 - Query
		StepNum = 30 - Add Atachment (from enter new data page)
		StepNum = 40 - SSN was in database already make edit or ignore entry
		StepNum = 50 - Reports / Exports
        Stepnum = 60 exports I think
        StpeNum = 70 - Delete Attachements (probably won't do it in a step but some other way)
		StepNum = 997 - Update Information
		StepNum = 998 - Insert Data into Database
		StepNum = 999 - Logout --->


<!DOCTYPE html>
<html lang="en"><!-- InstanceBegin template="/Templates/fullpage.dwt.cfm" codeOutsideHTMLIsLocked="false" -->

<head>
  	<!-- InstanceBeginEditable name="head" -->
	<!-- InstanceEndEditable -->
  <link rel="shortcut icon" href="https://www.mesa.k12.co.us/favicon.ico" />
	<link rel="stylesheet" type="text/css"  href="https://www.mesa.k12.co.us/css/text.css" />
   <link rel="stylesheet" type="text/css"  href="https://www.mesa.k12.co.us/css/main.css" />
   <!--[if lte IE 6]><link rel="stylesheet" type="text/css" href="../css/olderIESupport.css" />
<![endif]-->
	<link rel="stylesheet" type="text/css"  href="https://www.mesa.k12.co.us/css/print.css" media="print" />
 <script src="https://www.mesa.k12.co.us/scripts/main.js" type="text/javascript"></script>
	<script src="https://www.mesa.k12.co.us/SpryAssets/SpryMenuBar.js" type="text/javascript"></script>
	<link href="https://www.mesa.k12.co.us/SpryAssets/SpryMenuBarHorizontal.css" rel="stylesheet" type="text/css" />

	<!-- InstanceBeginEditable name="doctitle" -->
		<title></title>
	<!-- InstanceEndEditable -->

</head>

<body>
<div id="wrapper">
	<div id="headercontainer">
  	<div id="headerimages"> <a href="https://www.d51schools.org"><img src="https://www.mesa.k12.co.us/images/logo.jpg" align="left" alt="Mesa County Valley School District 51"></a>
 <!---			<cfinclude template="/2003/templates/components/rotatingphotos.cfm" />--->
		</div>
		<div id="headersprybar">
  		<!---<cfinclude template="/2003/templates/components/sprybar.cfm" />--->
		</div> 
	</div>
<!---	<div id="headersearchbar">
		<cfinclude template="/2003/templates/components/searchbar.cfm" />	
   </div>--->
	<div id="maincontainer">
  	<div id="maincontentfull">
    <main>
    	<h1><span class="heading"> 
					<!-- InstanceBeginEditable name="PageTitle" --><center>Finger Print</center><!-- InstanceEndEditable -->
   	  	</span></h1>
				 <!-- InstanceBeginEditable name="Content" -->
<!--- Set Initial StepNum --->
<cfif not isdefined('url.StepNum')>
	<cfset url.StepNum = 0>
</cfif>

<!--- StepNum = 0 not logged in or just logged out --->
<cfif url.StepNum eq 0>

<cfif not isdefined ('session.username')>
	<center>Please Log In.</center>	
	</cfif>

<!--- User Login --->
	<cfif not isdefined ('session.username') and not isdefined ('submitform')>
        
        <p>&nbsp; </p>
        
        <cfif isdefined('tryagain')>
            <pan class="red">Invalid Username or Password or you are unauthorized- - Try again</span>
            </div>
        </cfif>
        <center><cfform name="form" method="post" action="" width="500" height="550">
		<!---<cfformgroup type="panel" label="Leave Request Form">--->
		<table align="center"><tr><td align="center">
        Username: <cfinput name="username" type="text" size="20" label="Username:" onkeydown="if(Key.isDown(Key.ENTER)) Submituser.dispatchEvent({type:'click'});"><br />

 	 	Password: <cfinput name="password" type="password" size="20" label="Password:" onkeydown="if(Key.isDown(Key.ENTER)) Submituser.dispatchEvent({type:'click'});"><br />
    	<cfinput type="submit" name="Submituser" value="Submit">
        </td></tr></table>
   	</cfform></center>
    </cfif>
    <!--- Check Username and Password --->
	<cfif isdefined ("form.submituser")>        
		<!--- Test Validation vs AD --->
        <cftry>
        <cfldap action="query" 
           server="chief.mesa.k12.co.us" 
           name="GetAccounts" 
           start="DC=mesa,DC=k12,DC=co,DC=us"
           filter="(&(objectclass=user)(SamAccountName=#form.username#))"
           username="mesa\#form.username#" 
           password="#form.password#" 
           attributes = "cn,o,l,st,sn,c,mail,telephonenumber, givenname,homephone, streetaddress, postalcode, SamAccountname, physicalDeliveryOfficeName, department, memberof">
        <cfcatch>
            <cfset getaccounts.recordcount = 0>            
        </cfcatch>
        </cftry>
        <cfif getaccounts.recordcount eq 0>
            
            <!--- Log login attempt --->
            <cfquery name="LogFailed" datasource="hrinfopath">
                INSERT INTO tblFingerPrint_LogInfo
                    (DateTime, LogInfo, IPAddress, FPUser)    
                VALUES
                    (
                       <cfqueryparam value="#NOW()#" cfsqltype="cf_sql_timestamp">,
                       <cfqueryparam value="Failed login" cfsqltype="cf_sql_varchar" >,
                       <cfqueryparam value="#CGI.REMOTE_ADDR#" cfsqltype="cf_sql_varchar">,
                       <cfqueryparam value="MESA\#form.username#" cfsqltype="cf_sql_varchar">
                    )
            </cfquery>
            
            
            <cflocation url="index.cfm?tryagain" addtoken="no">
        <cfelseif #getaccounts.cn# eq 'bshay' or #getaccounts.cn# eq 'rachelt' or #getaccounts.cn# eq 'jenann' or #getaccounts.cn# eq 'lhudson' or #getaccounts.cn# eq 'crystal' or #getaccounts.cn# eq 'hart' or #getaccounts.cn# eq 'bchandle' or #getaccounts.cn# eq 'cness' or #getaccounts.cn# eq 'scalvert' or #getaccounts.cn# eq 'bnieslan' or #getaccounts.cn# eq 'bandrews' or #getaccounts.cn# eq 'kbeckel'>
			<!--- Log login attempt --->
            <cfquery name="LogFailed" datasource="hrinfopath">
                INSERT INTO tblFingerPrint_LogInfo
                    (DateTime, LogInfo, IPAddress, FPUser)    
                VALUES
                    (
                       <cfqueryparam value="#NOW()#" cfsqltype="cf_sql_timestamp">,
                       <cfqueryparam value="Successful login" cfsqltype="cf_sql_varchar" >,
                       <cfqueryparam value="#CGI.REMOTE_ADDR#" cfsqltype="cf_sql_varchar">,
                       <cfqueryparam value="MESA\#form.username#" cfsqltype="cf_sql_varchar">
                    )
            </cfquery>

            <cfset Session.Username = '#GetAccounts.cn#'>
            <cfset Session.Building = '#GetAccounts.physicaldeliveryofficename#'>
            <cfset Session.email = '#GetAccounts.mail#'>
            <cfquery name="GetUserinfo" datasource="accounts">
                SELECT     
                    Accounts.Username, Accounts.Building, Building.building_number, Accounts.Full_Name, Accounts.Groups, Accounts.SocSecNum
                FROM         
                    Accounts INNER JOIN
                              Building ON Accounts.Building = Building.Building
                WHERE
                    (ACCOUNTS.USERNAME = '#session.username#')
        	</cfquery>
            <cfif #GetUserInfo.RecordCount# gt 0>
				<cfset Session.BuildingNum = '#GetUserInfo.Building_number#'>
                <cfset Session.FullName = '#GetUserInfo.Full_Name#'>
                <cfset Session.Groups = '#GetUserInfo.Groups#'>
                <cfset Session.SSN = '#GetUserInfo.SocSecNum#'>
                <cflocation url="index.cfm?StepNum=1" addtoken="no">
            <cfelse>
                <cfquery name="LoginTracking" datasource="hrinfopath">
                    INSERT INTO tblFingerPrint_LogInfo
                        (DateTime, LogInfo, IPAddress, FPUser)    
                    VALUES
                        (
                        <cfqueryparam value="#NOW()#" cfsqltype="cf_sql_timestamp">,
                        <cfqueryparam value="Successful login - NO Access" cfsqltype="cf_sql_varchar" >,
                        <cfqueryparam value="#CGI.REMOTE_ADDR#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="MESA\#form.username#" cfsqltype="cf_sql_varchar">
                        )
                </cfquery>
            	<cflocation url="index.cfm?tryagain" addtoken="no">
            </cfif>
        <cfelse>
            <cfquery name="LogFailed" datasource="hrinfopath">
                INSERT INTO tblFingerPrint_LogInfo
                    (DateTime, LogInfo, IPAddress, FPUser)    
                VALUES
                    (
                       <cfqueryparam value="#NOW()#" cfsqltype="cf_sql_timestamp">,
                       <cfqueryparam value="Failed login" cfsqltype="cf_sql_varchar" >,
                       <cfqueryparam value="#CGI.REMOTE_ADDR#" cfsqltype="cf_sql_varchar">,
                       <cfqueryparam value="MESA\#form.username#" cfsqltype="cf_sql_varchar">
                    )
            </cfquery>

        	<cflocation url="index.cfm?tryagain" addtoken="no">
        </cfif>    
    </cfif>
<!--- Select Enter New or Query old --->
<cfelseif url.Stepnum eq 1>

<cfif isdefined('form.submit')>
	<cfif not isdefined('form.selection')>
    <cfelse>
		<cfif form.selection eq 'N'>
            <cflocation url="index.cfm?StepNum=10">
        <cfelseif form.selection eq 'Q'>
            <cflocation url="index.cfm?StepNum=20">
        <cfelseif form.selection eq 'R'>
        	<cflocation url="index.cfm?StepNum=50">
        <cfelse>
         </cfif>	
	</cfif>
</cfif>
	<cfform name="Select" action="index.cfm?Stepnum=1" method="post">
    	<table width="100%">
        	<tr>
            	<td align="right" width="50%">Select to Enter New Data</td>
                <td align="left" width="50%"><cfinput type="radio" name="selection" value="N"></td>
            </tr>
            <tr>
            	<td align="right" width="50%">Select to Query Data</td>
                <td align="left" width="50%"><cfinput type="radio" name="selection" value="Q"></td>
            </tr>
            <tr>
            	<td align="right" width="50%">Select to go to Reports/Exports</td>
                <td align="left" width="50%"><cfinput type="radio" name="selection" value="R"></td>
            </tr>
            <tr>
            	<td colspan="2" align="center"><cfinput type="submit" name="submit" value="Next"></td>
            </tr>
        </table>
    </cfform>
<!--- Enter New Data --->
<cfelseif url.Stepnum eq 10>
	
    <!--- logout --->
    <cfif isdefined('form.logout')>    
    	<cflocation url="index.cfm?StepNum=999">
    </cfif>
	
	<!--- set session variables for inserting into database --->
	<cfif isdefined('form.submit')>
    	<cfif isdefined('form.cbVolunteer')>
    		<cfset Session.Volunteer = '#form.cbVolunteer#'>
        <cfelse>
        	<cfset Session.Volunteer = ''>
        </cfif>
        <cfif isdefined('form.cbDisconnected')>
    		<cfset Session.Disconnected = '#form.cbDisconnected#'>
        <cfelse>
        	<cfset Session.Disconnected = ''>
        </cfif>
        <cfset Session.LName = '#form.tbLName#'>
        <cfset Session.FName = '#form.tbFName#'>
        <cfset Session.SSN = '#form.tbSSN#'>
        <cfset Session.FLName = '#form.tbFLName#'>
        <cfset Session.DOB = '#form.tbDOB#'>
        <cfset Session.FPDate = '#form.tbFPDate#'>
        <cfif isdefined('form.cbFPUnread')>
        	<cfset Session.FPUnread = '#form.cbFPUnread#'>
        <cfelse>
        	<cfset Session.FPUnread = ''>
        </cfif>
        <cfset Session.Attachment = '#form.rbAttachment#'>
        <cfset Session.Undetermined = '#form.rbUndetermined#'>
        <cfset Session.Misdemeanor = '#form.rbMisdemeanor#'>
        <cfset Session.Felony = '#form.rbFelony#'>
        <cfset Session.Comments = '#form.taComments#'>
        <cfif isdefined('form.cbDoNotrehire')>
        	<cfset Session.DoNotRehire = '#form.cbDoNotRehire#'>
        <cfelse>
        	<cfset Session.DoNotRehire = ''>
        </cfif>
        <cfif isdefined('form.cbJRE')>
        	<cfset Session.JRE = '#form.cbJRE#'>
        <cfelse>
        	<cfset Session.JRE = ''>
        </cfif>
        <cfif isdefined('form.cbMVCS')>
        	<cfset Session.MVCS = '#form.cbMVCS#'>
        <cfelse>
        	<cfset Session.MVCS = ''>
        </cfif>
        <cfif isdefined('form.cbIA')>
        	<cfset Session.IA = '#form.cbIA#'>
        <cfelse>
        	<cfset Session.IA = ''>
        </cfif>       
        <cfset Session.Address = '#form.tbAddress#'>
        <cfset Session.City = '#form.tbCity#'>
        <cfset Session.State = '#form.selState#'>
        <cfset Session.Zip = '#form.tbZip#'>
        <cfset Session.Phone = '#form.tbPhone#'>
        <cfset Session.Email = '#form.tbEmail#'>
        
        <cfif isdefined('form.cbStuTeach')>
    		<cfset Session.StuTeach = '#form.cbStuTeach#'>
        <cfelse>
        	<cfset Session.StuTeach = ''>
        </cfif>
        
        <cfif isdefined('form.cbStuTeachCDE')>
        	<cfset Session.StuTeachCDE = '#form.cbStuTeachCDE#'>
        <cfelse>
        	<cfset Session.StuTeachCDE = ''>
        </cfif>
        
        <cfif isdefined('form.cbSTA')>
    		<cfset Session.STA = '#form.cbSTA#'>
        <cfelse>
        	<cfset Session.STA = ''>
        </cfif>
        
        <cfset Session.UpdatedBy = '#Session.FullName#'>
        <cfset Session.UpdatedOn = #LSDateFormat(NOW(),'mm/dd/yyyy')#>
 		        
        <cflocation url="index.cfm?StepNum=998">
    </cfif>
    
    <!--- Enter new data form --->
    <cfform name="EnterNew" method="post" action="index.cfm?StepNum=10">
    	<table width="100%" border="1">
        	<th align="center" colspan="4">Enter New Information</th>
            <tr>
            	<td width="20%"><cfinput type="checkbox" name="cbSTA"> STA</td>
                <td width="30%"><cfinput type="checkbox" name="cbStuTeach"> 
                Student Teacher (FP with D51)     <cfinput type="checkbox" name="cbStuTeachCDE">Student Teacher / Contractor (FP with CDE)</td>
                <td width="30%"><cfinput type="checkbox" name="cbDisconnected"> Disconnected</td>
                <td width="20%"><cfinput type="checkbox" name="cbVolunteer"> Volunteer</td>
            </tr>
            <tr>
            	<td width="20%">Last Name:</td>
                <td width="30%"><cfinput type="text" name="tbLName"></td>
                <td width="20%">First Name:</td>
                <td width="30%"><cfinput type="text" name="tbFName"></td>
            </tr>
            <tr>
            	<td width="20%">Social Security #:</td>
                <td width="30%"><cfinput type="text" name="tbSSN" validate="social_security_number" message="you must enter a valid social security number" mask="XXX-XX-XXXX"></td>
                <td width="20%">Former Last Name:</td>
                <td width="30%"><cfinput type="text" name="tbFLName"></td>
            </tr>
            <tr>
            	<td width="20%">Date of Birth:</td>
                <td width="30%"><cfinput type="text" name="tbDOB" mask="XX/XX/XXXX"></td>
                <td width="20%">Finger Print Date:</td>
                <td width="30%"><cfinput type="text" name="tbFPDate" mask="XX/XX/XXXX"></td>
            </tr>
            <tr>
            	<td colspan="4"><cfinput type="checkbox" name="cbFPUnread"> Record Returned - FP unreadable - employee will need to be fingerprinted again </td>
            </tr>
            <tr>
            	<td width="20%">Attachments:</td>
                <td width="30%"><cfinput type="radio" name="rbAttachment" value="Y"> Yes <cfinput type="radio" name="rbAttachment" value="N" checked="yes"> No</td>
                <td width="20%">Undetermined</td>
                <td width="30%"><cfinput type="radio" name="rbUndetermined" value="Y"> Yes <cfinput type="radio" name="rbUndetermined" value="N" checked="yes"> No</td>
            </tr>
            <tr>
            	<td width="20%">Misdemeanor Charges:</td>
                <td width="30%"><cfinput type="radio" name="rbMisdemeanor" value="Y"> Yes <cfinput type="radio" name="rbMisdemeanor" value="N" checked="yes"> No</td>
                <td width="20%">Felony Charges:</td>
                <td width="30%"><cfinput type="radio" name="rbFelony" value="Y"> Yes <cfinput type="radio" name="rbFelony" value="N" checked="yes"> No</td>
            </tr>
            <tr>
            	<td>Comments</td>
                <td colspan="1"><cftextarea name="taComments" rows="4" cols="60"></cftextarea></td>
                <td>
                	<cfinput type="checkbox" name="cbJRE"> Juniper Ridge<br />
                    <cfinput type="checkbox" name="cbMVCS"> Mesa Valley Community School<br />
                    <cfinput type="checkbox" name="cbIA"> Independence Academy
                </td>
                <td><cfinput type="checkbox" name="cbDoNotRehire"> Do Not Rehire</td>
            </tr>
            <tr>
            	<td colspan="4"><hr /></td>
            </tr>
            <tr>
            	<td colspan="4">Street Address: <cfinput type="text" name="tbAddress" size="150"></td>
            </tr>
            <tr>
            	<td colspan="2">City: <cfinput type="text" name="tbCity" size="75"></td>
                <cfquery name="states" datasource="hrinfopath">
                	SELECT	StateCode, State
                    FROM	tblFP_States
                    ORDER BY	State
                </cfquery>
                <td>State: <cfselect name="selState" query="states" display="State" value="StateCode"></cfselect></td>
                <td>Zip Code:  <cfinput type="text" name="tbZip"></td>
            </tr>
            <tr>
            	<td colspan="4">Phone Number: <cfinput type="text" name="tbPhone" size="150"></td>
            </tr>
            <tr>
            	<td colspan="4">E-Mail Address: <cfinput type="text" name="tbEmail" size="150"></td>
            </tr>
            <tr>
            	<td colspan="2" align="center"><cfinput type="submit" name="submit" value="Submit"></td>
                <td colspan="2" align="center"><cfinput type="submit" name="logout" value="Logout"></td>
            </tr>
        </table>
    </cfform>
    
<!--- Query old data --->
<cfelseif url.StepNum eq 20>

	<cfif isdefined('form.select')>
    	<cflocation url="index.cfm?StepNum=1">
    </cfif>
	<cfif isdefined('form.search')>
    	<cfquery name="SearchFP" datasource="hrinfopath">
        	SELECT	*
            FROM	tblFingerPrintDB
            WHERE	FPID is not null
					<cfif #form.SLName# gt ''> and LName LIKE '%#form.SLName#%'</cfif>
            		<cfif #form.SFName# gt ''> and FName LIKE '%#form.SFName#%'</cfif>
                    <cfif #form.S_SSN# gt ''> and SSN LIKE '%#form.S_SSN#%'</cfif>
                    <cfif #form.SFLName# gt ''> and FormerLName LIKE '%#form.SFLName#%'</cfif>
                    <cfif isdefined('form.S_StuTeachCDE')>
						<cfif #form.S_StuTeachCDE# eq 'on'> and StudentTeacherCDE = 'on'</cfif>
                    </cfif>
            order by lname, fname, formerlname, ssn
        </cfquery>
        
        <cfoutput>
            <table border="1" width="100%">
            	<tr>
                	<td colspan="7">
                    	Searching for Last Name: #form.SLName#, First Name: #form.SFName#, SSN: #form.S_SSN#, Former Last Name: #form.SFLName#, Student Teacher (FP with CDE) <cfif isdefined('form.S_StuTeachCDE')> YES</cfif>
                	</td>
                </tr>
            	<tr>
                	<td>Last Name</td>
                    <td>First Name</td>
                    <td>SSN</td>
                    <td>Former Last Name</td>
                    <td>DOB</td>
                    <td>Disconnected</td>
                    <td>Student Teacher (FP with CDE)</td>
                </tr>
                <cfloop from="1" to="#SearchFP.RecordCount#" index="i">
                	<tr>
                    	<td><a href="index.cfm?StepNum=21&fpid=#SearchFP.FPID[i]#">#SearchFP.LName[i]#</a></td>
                        <td>#SearchFP.FName[i]#</td>
                        <td>#SearchFP.SSN[i]#</td>
                        <td>&nbsp;#SearchFP.FormerLName[i]#</td>
                        <td>&nbsp;#LSDateFormat(SearchFP.DOB[i], 'mm/dd/yyyy')#</td>
                        <td>
                            <cfif #SearchFP.Disconnected# eq 'on'>
                            	Yes
                            <cfelse>
                            	&nbsp;
                            </cfif>
                        </td>
                       	<td>
                        	<cfif #SearchFP.StudentTeacherCDE# eq 'on'>
                            	Yes
                            <else>
                            	&nbsp;
                            </cfif>
                        </td>
                    </tr>	    
                </cfloop>
            </table>
        </cfoutput>
        
    </cfif>

	<cfform name="Search" method="post" action="index.cfm?StepNum=20">
    	<center>
    		<table>
            	<tr>
                	<td colspan="2" align="center">Search By:</td>
                </tr>
                <tr>
                	<td>Last Name:</td>
                    <td><cfinput type="text" name="SLName"></td>
                </tr>
                <tr>
                	<td>First Name:</td>
                    <td><cfinput type="text" name="SFName"></td>
                </tr>
                <tr>
                	<td>SSN:</td>
                    <td><cfinput type="text" name="S_SSN" mask="XXX-XX-XXXX"></td>
                </tr>
                <tr>
                	<td>Former Last Name:</td>
                    <td><cfinput type="text" name="SFLName"></td>
                </tr>
                <tr>
                	<td colspan="2">
                    	<cfinput type="checkbox" name="S_StuTeachCDE"> Stduent Teacher (FP with CDE)
                    </td>
                </tr>
                <tr>
                	<td colspan="2"><cfinput type="submit" name="search" value="Search"></td>
                </tr>
            </table>
        </center>
        <center><cfinput type="submit" name="select" value="Return To Select"></center>
    </cfform>

<!--- Show individual FP record --->
<cfelseif url.StepNum eq 21>

<cfif isdefined('form.add')>
	<cflocation url="index.cfm?StepNum=30&update=Y">
</cfif>

<cfif isdefined('form.select')>
	<cflocation url="index.cfm?StepNum=1">
</cfif>

<cfif isdefined('form.update')>
	<cfif isdefined('form.cbVolunteer')>
		<cfset Session.Volunteer = '#form.cbVolunteer#'>
    <cfelse>
        <cfset Session.Volunteer = ''>
    </cfif>
    <cfif isdefined('form.cbDisconnected')>
		<cfset Session.Disconnected = '#form.cbDisconnected#'>
    <cfelse>
        <cfset Session.Disconnected = ''>
    </cfif>
    <cfset Session.LName = '#form.tbLName#'>
    <cfset Session.FName = '#form.tbFName#'>
    <cfset Session.SSN = '#form.tbSSN#'>
    <cfset Session.FLName = '#form.tbFLName#'>
    <cfset Session.DOB = '#form.tbDOB#'>
    <cfset Session.FPDate = '#form.tbFPDate#'>
    <cfif isdefined('form.cbFPUnread')>
        <cfset Session.FPUnread = '#form.cbFPUnread#'>
    <cfelse>
        <cfset Session.FPUnread = ''>
    </cfif>
    <cfset Session.Attachment = '#form.rbAttachment#'>
    <cfset Session.Undetermined = '#form.rbUndetermined#'>
    <cfset Session.Misdemeanor = '#form.rbMisdemeanor#'>
    <cfset Session.Felony = '#form.rbFelony#'>
    <cfset Session.Comments = '#form.taComments#'>
    <cfif isdefined('form.cbDoNotrehire')>
        <cfset Session.DoNotRehire = '#form.cbDoNotRehire#'>
    <cfelse>
        <cfset Session.DoNotRehire = ''>
    </cfif> 
    <cfif isdefined('form.cbJRE')>
        <cfset Session.JRE = '#form.cbJRE#'>
    <cfelse>
        <cfset Session.JRE = ''>
    </cfif> 
	<cfif isdefined('form.cbMVCS')>
        <cfset Session.MVCS = '#form.cbMVCS#'>
    <cfelse>
        <cfset Session.MVCS = ''>
    </cfif> 
	<cfif isdefined('form.cbIA')>
        <cfset Session.IA = '#form.cbIA#'>
    <cfelse>
        <cfset Session.IA = ''>
    </cfif>        
    <cfset Session.Address = '#form.tbAddress#'>
    <cfset Session.City = '#form.tbCity#'>
    <cfset Session.State = '#form.selState#'>
    <cfset Session.Zip = '#form.tbZip#'>
    <cfset Session.Phone = '#form.tbPhone#'>
    <cfset Session.Email = '#form.tbEmail#'>

    <cfif isdefined('form.cbStuTeach')>
		<cfset Session.StuTeach = '#form.cbStuTeach#'>
    <cfelse>
        <cfset Session.StuTeach = ''>
    </cfif>
    
    <cfif isdefined('form.cbStuTeachCDE')>
    	<cfset Session.StuTeachCDE = '#form.cbStuTeachCDE#'>
    <cfelse>
    	<cfset Session.StuTeachCDE = ''>
    </cfif>
    
    <cfif isdefined('form.cbSTA')>
		<cfset Session.STA = '#form.cbSTA#'>
    <cfelse>
        <cfset Session.STA = ''>
    </cfif>
    
    <cfset Session.UpdatedBy = '#Session.FullName#'>
    <cfset Session.UpdatedOn = #LSDateFormat(NOW(),'mm/dd/yyyy')#>
            
    <cflocation url="index.cfm?StepNum=997">
</cfif>

<cfif isdefined('form.search')>
	<cflocation url="index.cfm?StepNum=20">
</cfif>

<cfif isdefined('form.logout')>
	<cflocation url="index.cfm?StepNum=999">
</cfif>

<cfset Session.FPID = #url.FPID#>

<!--- Query to get FP Data --->
<cfquery name="GetData" datasource="hrinfopath">
	SELECT	*
    FROM	tblFingerPrintDB
    WHERE	FPID = #Session.FPID#
</cfquery>

    <!--- Log Viewing Data --->
    <cfquery name="LogInsert" datasource="hrinfopath">
        INSERT INTO tblFingerPrint_LogInfo
            (DateTime, LogInfo, IPAddress, FPUser)    
        VALUES
            (
                <cfqueryparam value="#NOW()#" cfsqltype="cf_sql_timestamp">,
                <cfqueryparam value="Viewing Data - FAPID: #Session.FPID#" cfsqltype="cf_sql_varchar" >,
                <cfqueryparam value="#CGI.REMOTE_ADDR#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="MESA\#Session.Username#" cfsqltype="cf_sql_varchar">
            )
    </cfquery>
	
        <cfform name="Update" method="post" action="index.cfm?StepNum=21">
        	<table width="100%" border="1">
                <th align="center" colspan="4">Enter New Information</th>
                <tr>
                    <td width="20%">
                    	<cfoutput>
							<cfif #GetData.STA# eq 'on'>
                                <cfinput type="checkbox" name="cbSTA" checked="yes"> STA
                            <cfelse>
                                <cfinput type="checkbox" name="cbSTA"> STA
                            </cfif> 
                        </cfoutput>
                    </td>
                    <td width="20%">
                    	<cfoutput>
							<cfif #GetData.StudentTeacher# eq 'on'>
                                <cfinput type="checkbox" name="cbStuTeach" checked="yes"> Student Teacher (FP with D51)
                            <cfelse>
                                <cfinput type="checkbox" name="cbStuTeach"> Student Teacher (FP with D51)
                            </cfif> 
                        	<cfif #GetData.StudentTeacherCDE# eq 'on'>
                            	<cfinput type="checkbox" name="cbStuTeachCDE" checked="yes"> Student Teacher / Contractor (FP with CDE)
                            <cfelse>
                            	<cfinput type="checkbox" name="cbStuTeachCDE"> Student Teacher / Contractor (FP with CDE)
                            </cfif>
						</cfoutput>
                    </td>
                    <td width="20%">
                    	<cfoutput>
							<cfif #GetData.Disconnected# eq 'on'>
                                <cfinput type="checkbox" name="cbDisconnected" checked="yes"> Disconnected
                            <cfelse>
                                <cfinput type="checkbox" name="cbDisconnected"> Disconnected
                            </cfif> 
                        </cfoutput>
                    </td>
                    <td width="30%">
                    	<cfoutput>
							<cfif #GetData.Volunteer# eq 'on'>
                                <cfinput type="checkbox" name="cbVolunteer" checked="yes"> Volunteer
                            <cfelse>
                                <cfinput type="checkbox" name="cbVolunteer"> Volunteer
                            </cfif> 
                        </cfoutput>
                    </td>
                </tr>
                <tr>
                    <td width="20%">Last Name:</td>
                    <td width="30%"><cfinput type="text" name="tbLName" value="#GetData.LName#"></td>
                    <td width="20%">First Name:</td>
                    <td width="30%"><cfinput type="text" name="tbFName" value="#GetData.FName#"></td>
                </tr>
                <tr>
                    <td width="20%">Social Security #:</td>
                    <td width="30%"><cfinput type="text" name="tbSSN" value="#GetData.SSN#" mask="XXX-XX-XXXX"></td>
                    <td width="20%">Former Last Name:</td>
                    <td width="30%"><cfinput type="text" name="tbFLName" value="#GetData.FormerLName#"></td>
                </tr>
                <tr>
                    <td width="20%">Date of Birth:</td>
                    <td width="30%"><cfinput type="text" name="tbDOB" value="#LSDateFormat(GetData.DOB,'mm/dd/yyyy')#" mask="XX/XX/XXXX"></td>
                    <td width="20%">Finger Print Date:</td>
                    <td width="30%"><cfinput type="text" name="tbFPDate" value="#LSDateFormat(GetData.FPDate, 'mm/dd/yyyy')#" mask="XX/XX/XXXX"></td>
                </tr>
                <tr>
                    <td colspan="4">
                    	<cfoutput>
                        <cfif #GetData.FPUnread# eq 'on'>
                        	<cfinput type="checkbox" name="cbFPUnread" checked="yes"> Record Returned - FP unreadable - employee will need to be fingerprinted again
						<cfelse>
                        	<cfinput type="checkbox" name="cbFPUnread"> Record Returned - FP unreadable - employee will need to be fingerprinted again
                        </cfif>
                        </cfoutput> 
                    </td>
                </tr>
                <tr>
                    <td width="20%">Attachments:</td>
                    <td width="30%">
                    	<cfif #GetData.Attachment_yn# eq 'Y'>
                        	<cfinput type="radio" name="rbAttachment" value="Y" checked="yes"> Yes <cfinput type="radio" name="rbAttachment" value="N"> No
                        <cfelse>
                        	<cfinput type="radio" name="rbAttachment" value="Y" > Yes <cfinput type="radio" name="rbAttachment" value="N" checked="yes"> No
                        </cfif>
                        <cfif #GetData.Attachment_yn# eq 'Y'>
                        	Files:<br />
                            <cfquery name="GetAttachments" datasource="hrinfopath">
                            	SELECT	*
                                FROM	tblFP_AttachedFiles
                                WHERE	FP_EmpID = #Session.FPID#
                            </cfquery>
                            <cfif #GetAttachments.RecordCount# gt 0>
                            	<cfoutput>
                            	<cfloop from="1" to="#GetAttachments.RecordCount#" index="i">
                                	<!---<a href="\\ifasbitech\bi-tech$\HR Finger Print\Files\#GetAttachments.FileName[i]#" download>#GetAttachments.FileName[i]#</a><br />--->
                                	
                                	<!---<a href=".\Files\#GetAttachments.FileName[i]#" download>#GetAttachments.FileName[i]#</a><br />--->
                                	<!---<cfhttp method="Get" url="" path="\\ifasbitech\bi-tech$\HR Finger Print\Files\" file="#GetAttachments.FileName[i]#">#cfhttp.FileContent#<br>--->
                                	
                                </cfloop>
                                </cfoutput>
                                
                                <cfoutput>
                            	<cfloop from="1" to="#GetAttachments.RecordCount#" index="i">
                                	<!---<a href="\\ifasbitech\bi-tech$\HR Finger Print\Files\#GetAttachments.FileName[i]#" download>#GetAttachments.FileName[i]#</a><br />--->
                                	
                                	<a href=".\Files\#GetAttachments.FileName[i]#" download>#GetAttachments.FileName[i]#</a> - <a href="index.cfm?stepnum=70&fileid=#GetAttachments.index[i]#">delete</a><br />
                                	<!---<cfhttp method="Get" url="" path="\\ifasbitech\bi-tech$\HR Finger Print\Files\" file="#GetAttachments.FileName[i]#">#cfhttp.FileContent#<br>--->
                                	
                                </cfloop>
                                </cfoutput>
                                <cfinput type="submit" name="Add" value="Add File">
                            </cfif>
                        <cfelse>
                        	<cfinput type="submit" name="Add" value="Add File">
                        </cfif>    
                    </td>
                    <td width="20%">Undetermined Charges:</td>
                    <td width="30%">
                    	<cfif #GetData.Undetermined_yn# eq 'Y'>
                        	<cfinput type="radio" name="rbUndetermined" value="Y" checked="yes"> Yes <cfinput type="radio" name="rbUndetermined" value="N"> No
                        <cfelse>
                        	<cfinput type="radio" name="rbUndetermined" value="Y"> Yes <cfinput type="radio" name="rbUndetermined" value="N" checked="yes"> No
                        </cfif>
                    </td>
                </tr>
                <tr>
                    <td width="20%">Misdemeanor Charges:</td>
                    <td width="30%">
                    	<cfif #GetData.Misdemeanor_yn# eq 'Y'>
                        	<cfinput type="radio" name="rbMisdemeanor" value="Y" checked="yes"> Yes <cfinput type="radio" name="rbMisdemeanor" value="N"> No
                        <cfelse>
                        	<cfinput type="radio" name="rbMisdemeanor" value="Y"> Yes <cfinput type="radio" name="rbMisdemeanor" value="N" checked="yes"> No
                        </cfif>
                    </td>
                    <td width="20%">Felony Charges:</td>
                    <td width="30%">
                    	<cfif #GetData.Felony_yn# eq 'Y'>
                        	<cfinput type="radio" name="rbFelony" value="Y" checked="yes"> Yes <cfinput type="radio" name="rbFelony" value="N"> No
                        <cfelse>
                        	<cfinput type="radio" name="rbFelony" value="Y"> Yes <cfinput type="radio" name="rbFelony" value="N" checked="yes"> No
                        </cfif>
                    </td>
                </tr>
                <tr>
                    <td>Comments</td>
                    <td colspan="1"><cftextarea name="taComments" rows="4" cols="60" value="#GetData.comment#"></cftextarea></td>
                    <td>
                    	<cfif #GetData.JRE# eq 'on'>
                        	<cfinput type="checkbox" name="cbJRE" checked="yes"> Juniper Ridge<br />
                        <cfelse>
                        	<cfinput type="checkbox" name="cbJRE"> Juniper Ridge<br />
                        </cfif>
                        <cfif #GetData.MVCS# eq 'on'>
                        	<cfinput type="checkbox" name="cbMVCS" checked="yes"> Mesa Valley Community School<br />
                        <cfelse>
                        	<cfinput type="checkbox" name="cbMVCS"> Mesa Valley Community School<br />
                        </cfif>
                        <cfif #GetData.IA# eq 'on'>
                        	<cfinput type="checkbox" name="cbIA" checked="yes"> Independence Academy<br />
                        <cfelse>
                        	<cfinput type="checkbox" name="cbIA"> Independence Academy<br />
                        </cfif>
                    </td>
                    <td>
                    	<cfif #GetData.DoNotRehire# eq 'on'>
                        	<cfinput type="checkbox" name="cbDoNotRehire" checked="yes"> Do Not Rehire
                        <cfelse>
                        	<cfinput type="checkbox" name="cbDoNotRehire"> Do Not Rehire
                        </cfif>
                    </td>
                </tr>
                <tr>
                    <td colspan="4"><hr /></td>
                </tr>
                <tr>
                    <td colspan="4">Street Address: <cfinput type="text" name="tbAddress" size="150" value="#GetData.Address#"></td>
                </tr>
                <tr>
                    <td colspan="2">City: <cfinput type="text" name="tbCity" size="75" value="#GetData.City#"></td>
                    <cfquery name="states" datasource="hrinfopath">
                        SELECT	StateCode, State
                        FROM	tblFP_States
                        ORDER BY	State
                    </cfquery>
                    <td>State: <cfselect name="selState" query="states" display="State" value="StateCode" selected="#GetData.State#"></cfselect></td>
                    <td>Zip Code:  <cfinput type="text" name="tbZip" value="#GetData.Zip#"></td>
                </tr>
                <tr>
                    <td colspan="4">Phone Number: <cfinput type="text" name="tbPhone" size="150" value="#GetData.Phone#"></td>
                </tr>
                <tr>
                    <td colspan="4">E-Mail Address: <cfinput type="text" name="tbEmail" size="150" value="#GetData.Email#"></td>
                </tr>
                <tr>
                	<td colspan="2"><cfoutput>Last Updated By: #GetData.UpdatedBy#</cfoutput></td>
                    <td colspan="2"><cfoutput>Last Updated On: #LSDateFormat(GetData.UpdatedOn,'mm/dd/yyyy')#</cfoutput></td>
                </tr>
                <tr>
                    <td colspan="1" align="center"><cfinput type="submit" name="update" value="Update"></td>
                    <td colspan="1" align="center"><cfinput type="submit" name="select" value="Return to Select"></td>
                    <td colspan="1" align="center"><cfinput type="submit" name="search" value="Return to Search"></td>
                    <td colspan="1" align="center"><cfinput type="submit" name="logout" value="Logout"></td>
                </tr>
            </table>
        </cfform>

<!--- Get Attachment --->
<cfelseif url.StepNum eq 30> 

<!---old destination="\\ifasbitech\bi-tech$\HR Finger Print\Files\"--->

<cfif isDefined("form.fileUpload")>
	<cffile action="upload"
       		fileField="fileUpload"
         	destination="#ExpandPath("./Files")#"
            nameconflict="makeunique">
         	<p>Thank you, your file has been uploaded.</p>
     <cfset Session.FileName = '#cffile.serverFileName#.#cffile.serverfileext#'>
     <!--- Log Adding Attachment --->
    <cfquery name="LogAttachment2" datasource="hrinfopath">
        INSERT INTO tblFingerPrint_LogInfo
            (DateTime, LogInfo, IPAddress, FPUser)    
        VALUES
            (
                <cfqueryparam value="#NOW()#" cfsqltype="cf_sql_timestamp">,
                <cfqueryparam value="Uploading Document - FAPID: #Session.FPID# - #Session.FileName#" cfsqltype="cf_sql_varchar" >,
                <cfqueryparam value="#CGI.REMOTE_ADDR#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="MESA\#Session.Username#" cfsqltype="cf_sql_varchar">
            )
    </cfquery>
</cfif>

<cfif isDefined("form.fileUpload2") and #form.fileUpload2# gt ''>
	<cffile action="upload"
       		fileField="fileUpload2"
         	destination="#ExpandPath("./Files")#"
            nameconflict="makeunique">
         	<p>Thank you, your file has been uploaded.</p>
     <cfset Session.FileName2 = '#cffile.serverFileName#.#cffile.serverfileext#'>

     <!--- Log Adding Attachment --->
    <cfquery name="LogAttachment1" datasource="hrinfopath">
        INSERT INTO tblFingerPrint_LogInfo
            (DateTime, LogInfo, IPAddress, FPUser)    
        VALUES
            (
                <cfqueryparam value="#NOW()#" cfsqltype="cf_sql_timestamp">,
                <cfqueryparam value="Uploading Document - FAPID: #Session.FPID# - #Session.FileName2#" cfsqltype="cf_sql_varchar" >,
                <cfqueryparam value="#CGI.REMOTE_ADDR#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="MESA\#Session.Username#" cfsqltype="cf_sql_varchar">
            )
    </cfquery>
</cfif>

<cfif isdefined('Session.FileName') or isdefined('Session.FileName2')>
	<cfif isdefined('update')>
		<cflocation url="index.cfm?StepNum=996&update=Y">
    <cfelse>
    	<cflocation url="index.cfm?StepNum=996">
    </cfif>
</cfif>

<form enctype="multipart/form-data" method="post">
<input type="file" name="fileUpload" /><br />
<input type="file" name="fileUpload2" /><br />
<input type="submit" value="Upload File or Continue" />
</form>




<!--- StepNum 40 SSN was already in database --->
<cfelseif url.StepNum eq 40>
	
    <cfif isdefined('form.NewData')>
    	<cfset Session.LName = '#form.E_LName#'>
        <cfset Session.FName = '#form.E_FName#'>
        <cfset Session.SSN = '#form.E_SSN#'>
        <cfset Session.FLName = '#form.E_FormerLName#'>
        <cfset Session.DOB = '#form.E_DOB#'>
        <cfset Session.FPDate = '#form.E_FPDate#'>
        
        <cfset Session.UpdatedBy = '#Session.FullName#'>
        <cfset Session.UpdatedOn = #LSDateFormat(NOW(),'mm/dd/yyyy')#>
        
        <cflocation url="index.cfm?StepNum=998">
    </cfif>
    
    <cfif isdefined('form.EditExisting')>
    	<cfquery name="GetDataNew" datasource="hrinfopath">
            SELECT	*
            FROM 	tblFingerPrintDB
            WHERE	SSN = '#Session.SSN#'
        </cfquery>
        <cflocation url="index.cfm?StepNum=21&FPID=#GetDataNew.FPID#">
    </cfif>
    
	<h3><center>The SSN entered was already in the system.</center></h3>
    
    <cfquery name="GetData" datasource="hrinfopath">
    	SELECT	*
        FROM 	tblFingerPrintDB
        WHERE	SSN = '#Session.SSN#'
    </cfquery>
    <cfform name="CheckData" method="post" action="index.cfm?StepNum=40">
		<cfoutput>
            <table border="1" width="100%">
                <tr>
                    <td>&nbsp;</td>
                    <td align="center">Entered</td>
                    <td align="center">Already in System</td>
                </tr>
                <tr>
                    <td>Last Name:</td>
                    <td><cfinput type="text" name="E_LName" value="#Session.LName#"></td>
                    <td><cfinput type="text" name="S_LName" value="#GetData.LName#"></td>
                </tr>
                <tr>
                    <td>First Name:</td>
                    <td><cfinput type="text" name="E_FName" value="#Session.FName#"></td>
                    <td><cfinput type="text" name="S_FName" value="#GetData.FName#"></td>
                </tr>
                <tr>
                    <td>SSN:</td>
                    <td><cfinput type="text" name="E_SSN" value="#Session.SSN#" mask="XXX-XX-XXXX"></td>
                    <td><cfinput type="text" name="S_SSN" value="#GetData.SSN#" mask="XXX-XX-XXXX"></td>
                </tr>
                <tr>
                    <td>Former Last Name:</td>
                    <td><cfinput type="text" name="E_FormerLName" value="#Session.FLName#"></td>
                    <td><cfinput type="text" name="S_FormerLName" value="#GetData.FormerLName#"></td>
                </tr>
                <tr>
                    <td>Date of Birth:</td>
                    <td><cfinput type="text" name="E_DOB" value="#LSDateFormat(Session.DOB, 'mm/dd/yyyy')#"></td>
                    <td><cfinput type="text" name="S_DOB" value="#LSDateFormat(GetData.DOB, 'mm/dd/yyyy')#"></td>
                </tr>
                <tr>
                    <td>Date of Finger Printing:</td>
                    <td><cfinput type="text" name="E_FPDate" value="#LSDateFormat(Session.FPdate, 'mm/dd/yyyy')#"></td>
                    <td><cfinput type="text" name="S_FPDate" value="#LSDateFormat(GetData.FPdate, 'mm/dd/yyyy')#"></td>
                </tr>
                <tr>
                	<td>&nbsp;</td>
                    <td><cfinput type="submit" name="NewData" value="Data is Fixed - Submit"></td>
                    <td><cfinput type="submit" name="EditExisting" value="View Existing Record"></td>
                </tr>
            </table>
        </cfoutput>
    </cfform>

<!--- Update Attachment DB --->
<cfelseif url.StepNum eq 996>
	
    <cfif isdefined('Session.FileName')>
		<!--- INsert into Attachment DB --->
        <cfquery name="InsertDB" datasource="hrinfopath">
            INSERT INTO tblFP_AttachedFiles
                        (FP_EmpID, FileName)
            VALUES		('#Session.FPID#', '#Session.FileName#')
        </cfquery>
    </cfif>
    
    <cfif isdefined('Session.FileName2')>
		<!--- INsert into Attachment DB --->
        <cfquery name="InsertDB" datasource="hrinfopath">
            INSERT INTO tblFP_AttachedFiles
                        (FP_EmpID, FileName)
            VALUES		('#Session.FPID#', '#Session.FileName2#')
        </cfquery>
    </cfif>
    
    <cfset variables.Result = StructDelete(session, "FileName")>
    <cfset variables.Result = StructDelete(session, "FileName2")>
    
    <cfif isdefined('update')>
    	<cflocation url="index.cfm?StepNum=21&fpid=#Session.FPID#">
    <cfelse>
        <cflocation url="index.cfm?StepNum=1">
    </cfif>


<!--- Reports / Exports Selection --->
<cfelseif url.StepNum eq 50>
	
    <cfif isdefined('form.select')>
    	<cflocation url="index.cfm?StepNum=1">
    </cfif>
	<cfif isdefined('form.submit')>
    	<cfif #form.export# eq 'All'>
        	<cflocation url="index.cfm?StepNum=51">
        <cfelseif #form.export# eq 'Query'>
        	<cflocation url="index.cfm?StepNum=52">
        <cfelseif #form.export# eq 'Vol'>
        	<cflocation url="index.cfm?StepNum=54">
        <cfelseif #form.export# eq 'DNR'>
        	<cflocation url="index.cfm?StepNum=55">
        <cfelseif #form.export# eq 'Felony'>
        	<cflocation url="index.cfm?StepNum=56">
        <cfelseif #form.export# eq 'Mis'>
        	<cflocation url="index.cfm?StepNum=57">
        <cfelseif #form.export# eq 'Unread'>
        	<cflocation url="index.cfm?StepNum=58">
        <cfelseif #form.export# eq 'Active'>
        	<cflocation url="index.cfm?StepNum=59">
        <cfelseif #form.export# eq 'ST'>
        	<cflocation url="index.cfm?StepNum=60">
        <cfelseif #form.export# eq 'STA'>
        	<cflocation url="index.cfm?StepNum=61">
        </cfif>
    </cfif>
    
    <cfform name="selectexport" method="post" action="index.cfm?StepNum=50">
    	<center>Select Export: 	<cfselect name="Export">
        					<option value="All">All Data</option>
                            <option value="Active">Active Only</option>
                            <option value="Query">By Name, SSN</option>
                            <option value="Vol">Volunteer - Yes</option>
                            <option value="DNR">Do Not Rehire - Yes</option>
                            <option value="Felony">Felony - Yes</option>
                            <option value="Mis">Misdemeanor - Yes</option>
                            <option value="Unread">Finger Print Unreadable - Yes</option>
                            <option value="ST">Student Teacher</option>
                            <option value="STA">STA</option>
        				</cfselect></center><br />
        <center><cfinput type="submit" name="Submit" value="Submit"></center>
        <center><cfinput type="submit" name="select" value="Return To Select"></center>
    </cfform>

<!--- Export All Data --->
<cfelseif url.StepNum eq 51>
	<cfinclude template="ExportAll.cfm">
    
<!--- Search By Name or SSN --->
<cfelseif url.StepNum eq 52>
	<cfif isdefined('form.search')>
    	<cfset Session.Search_LName = '#Form.SLName#'>
        <cfset Session.Search_FName = '#Form.SFName#'>
        <cfset Session.Search_SSN = '#Form.S_SSN#'>
        <cfset Session.Search_FLName = '#form.SFLName#'>
        
        <cflocation url="index.cfm?StepNum=53">
    </cfif>

	<cfform name="Search" method="post" action="index.cfm?StepNum=52">
    	<center>
    		<table>
            	<tr>
                	<td colspan="2" align="center">Search By:</td>
                </tr>
                <tr>
                	<td>Last Name:</td>
                    <td><cfinput type="text" name="SLName"></td>
                </tr>
                <tr>
                	<td>First Name:</td>
                    <td><cfinput type="text" name="SFName"></td>
                </tr>
                <tr>
                	<td>SSN:</td>
                    <td><cfinput type="text" name="S_SSN" mask="XXX-XX-XXXX"></td>
                </tr>
                <tr>
                	<td>Former Last Name:</td>
                    <td><cfinput type="text" name="SFLName"></td>
                </tr>
                <tr>
                	<td colspan="2"><cfinput type="submit" name="search" value="Search"></td>
                </tr>
            </table>
        </center>
    </cfform>
    
<cfelseif url.StepNum eq 53>
	<cfinclude template="ExportBy.cfm">
    
<!--- Export All Volunteers--->
<cfelseif url.StepNum eq 54>
	<cfinclude template="ExportVolunteer.cfm">
    
<!--- Export All DNR's--->
<cfelseif url.StepNum eq 55>
	<cfinclude template="Export_DNR.cfm">
    
<!--- Export All Felonies--->
<cfelseif url.StepNum eq 56>
	<cfinclude template="ExportFelony.cfm">

<!--- Export All Felonies--->
<cfelseif url.StepNum eq 57>
	<cfinclude template="ExportMisdemeanor.cfm">

<!--- Export All Felonies--->
<cfelseif url.StepNum eq 58>
	<cfinclude template="ExportUnread.cfm">
    
<!--- Export All Actives --->
<cfelseif url.StepNum eq 59>
	<cfinclude template="ExportActive.cfm">

<!--- Export All Actives --->
<cfelseif url.StepNum eq 60>
	<cfinclude template="ExportStuTeach.cfm">
    
<!--- Export All STA --->
<cfelseif url.StepNum eq 61>
	<cfinclude template="ExportSTA.cfm">

<!--- Delete Attachements --->
<cfelseif url.StepNum eq 70>
    <!--- &fpid=#SearchFP.FPID[i]# --->
    <cfif isdefined('form.delete')>
        <!--- Get file name --->
        
        <cfquery name="getFileInfo" datasource="hrinfopath">
            SELECT *
            FROM tblFP_AttachedFiles
            WHERE [index] = #url.fileid#        
        </cfquery>
        
        <cfoutput>fileid: #url.fileid#<br>File Name: <a href=".\Files\#getFileInfo.FileName#">#getFileInfo.FileName#</a><br><br></cfoutput>

        <!--- delete file from directory  --->
        <cftry>
            <!--- <cffile action="delete" file="D:\intranet\2003\apps\FingerPrintNew\Files\#getFileInfo.FileName#"> --->
            <cfset filePath = expandPath("./Files/#getFileInfo.FileName#")>
            <cffile action="delete" file="#filePath#">
        <cfcatch type="Any">
            <cflog file="deleteFileError" text="Error Deleting File: #cfcatch.Message# - #cfcatch.Detail#">
            <cfoutput >
                Error Message: #cfcatch.Message#<br>
                Error Detail: #cfcatch.Detail#<br>
                Error Type: #cfcatch.Type#<br>
            </cfoutput>
        </cfcatch>
        </cftry>

        <cfset tempFPEMPID = #url.fpid#>
        <cfset tempFileID = #url.fileid#>

        <!--- delete from database --->
        <cftry>
            <cfquery name="DeletFromDB" datasource="hrinfopath">
                DELETE FROM tblFP_AttachedFiles
                WHERE FP_EmpID = <cfqueryparam value="#tempFPEMPID#" cfsqltype="cf_sql_integer">
                    AND [index] = <cfqueryparam value="#tempFileID#" cfsqltype="cf_sql_integer">
            </cfquery>
            <cfcatch type="any">
                <cfoutput>Error deleting record: #cfcatch.message#"</cfoutput>                    
            </cfcatch>
        </cftry>

        <!--- Log Delete attempt --->
        <cfquery name="LogDelete" datasource="hrinfopath">
            INSERT INTO tblFingerPrint_LogInfo
                (DateTime, LogInfo, IPAddress, FPUser)    
            VALUES
                (
                    <cfqueryparam value="#NOW()#" cfsqltype="cf_sql_timestamp">,
                    <cfqueryparam value="Delete File for #Session.FPID#" cfsqltype="cf_sql_varchar" >,
                    <cfqueryparam value="#CGI.REMOTE_ADDR#" cfsqltype="cf_sql_varchar">,
                    <cfqueryparam value="MESA\#Session.username#" cfsqltype="cf_sql_varchar">
                )
        </cfquery>

        <!--- return to stepnum = 21 ---> 
        <cflocation url="index.cfm?StepNum=21&fpid=#Session.FPID#">
    </cfif>

    <!--- <cfoutput>Deleting File for FPID #Session.FPID# file id: #url.fileid#</cfoutput> --->
    
    <!--- Get file info for fileid --->
    <cfif isdefined('url.fileid')>
        <cfquery name="getFileInfo" datasource="hrinfopath">
            SELECT *
            FROM tblFP_AttachedFiles
            WHERE [index] = #url.fileid#        
        </cfquery>
        <cfoutput>file id is: "#url.fileid#" </cfoutput>
        <!--- Get Emp information --->
        <cfquery name="GetData" datasource="hrinfopath">
            SELECT	*
            FROM	tblFingerPrintDB
            WHERE	FPID = #Session.FPID#
        </cfquery>

        <cfform name="deleteFiles" method="post" action="index.cfm?StepNum=70&fileid=#url.fileid#&fpid=#getFileInfo.FP_EmpID#">
            <center>
                <table>
                    <tr>
                        <td colspan="2" align="center">Delete File</td>
                    </tr>
                    <tr>
                        <td colspan="2" align="center"><cfoutput>#GetData.FName# #GetData.LName#</cfoutput> </td>
                    </tr>
                    <tr>
                        <td colspan="2" align="center"><cfoutput>#getFileInfo.FP_EmpID#</cfoutput></td>
                    </tr>
                    <tr>
                        <td>File Name:</td>
                        <td><cfoutput>#getFileInfo.FileName#</cfoutput></td>
                    </tr>
                    <tr>
                        <td colspan="2" align="center"><cfinput type="submit" name="delete" value="Delete"></td>
                    </tr>
                </table>
            </center>
        </cfform>
    </cfif>

<!--- Update Data --->
<cfelseif url.Stepnum eq 997>
	<cfquery name="update" datasource="hrinfopath">
    	UPDATE	tblFingerPrintDB
        SET		LName = '#Session.LName#',
        		FName = '#Session.FName#', 
                SSN = '#Session.SSN#', 
                FormerLName = '#Session.FLName#', 
                DOB = '#Session.DOB#', 
                FPDate = '#Session.FPDate#', 
                FPUnRead = '#Session.FPUnread#', 
                Attachment_yn = '#Session.Attachment#',
                Undetermined_yn = '#Session.Undetermined#', 
                Misdemeanor_yn = '#Session.Misdemeanor#',
                Felony_yn = '#Session.Felony#', 
                comment = '#Session.Comments#', 
                DoNotRehire = '#Session.DoNotRehire#', 
                Address = '#Session.Address#', 
                City = '#Session.City#', 
                State = '#Session.State#', 
                Zip = '#Session.Zip#', 
                Phone = '#Session.Phone#', 
                EMail = '#Session.Email#', 
                Volunteer = '#Session.Volunteer#',
                Disconnected = '#Session.Disconnected#', 
                UpdatedBy = '#Session.UpdatedBy#', 
                UpdatedOn = '#Session.UpdatedOn#',
                StudentTeacher = '#Session.StuTeach#',
                STA = '#Session.STA#',
                JRE = '#Session.JRE#',
                MVCS = '#Session.MVCS#',
                IA = '#Session.IA#',
                StudentTeacherCDE = '#Session.StuTeachCDE#'
        WHERE	FPID = '#Session.FPID#'
    </cfquery>

    <!--- Log Updating Data --->
    <cfquery name="LogInsert" datasource="hrinfopath">
        INSERT INTO tblFingerPrint_LogInfo
            (DateTime, LogInfo, IPAddress, FPUser)    
        VALUES
            (
                <cfqueryparam value="#NOW()#" cfsqltype="cf_sql_timestamp">,
                <cfqueryparam value="Updating Data for - FAPID: #Session.FPID#" cfsqltype="cf_sql_varchar" >,
                <cfqueryparam value="#CGI.REMOTE_ADDR#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="MESA\#Session.Username#" cfsqltype="cf_sql_varchar">
            )
    </cfquery>
    
    <cflocation url="index.cfm?StepNum=20">
<!--- INsert Data --->
<cfelseif url.Stepnum eq 998>
	
    <!--- check to see if SSN is in database --->
    <cfquery name="CheckSSN" datasource="hrinfopath">
    	SELECT	*
        FROM	tblFingerPrintDB
        WHERE	SSN = '#Session.SSN#'
    </cfquery>
    
    <cfif #CheckSSN.RecordCount# gt 0>
    	<cflocation url="index.cfm?StepNum=40">
    </cfif>
    
    <!--- get ID Number --->
    <cfquery name="GetMaxID" datasource="hrinfopath">
    	SELECT	MAX(FPID) as MAXID
        FROM	tblFingerPrintDB
    </cfquery>
    
    <cfif #GetMaxID.RecordCount# eq 0>
    	<cfset Session.FPID = 1>
    <cfelse>
    	<cfset Session.FPID = #GetMaxID.MAXID# + 1>
    </cfif>
    
    <!--- insert into database --->
    <cfquery name="Insert" datasource="hrinfopath">
    	INSERT INTO tblFingerPrintDB
        			(FPID, LName, FName, SSN, FormerLName, DOB, FPDate, FPUnRead, Attachment_yn, Undetermined_yn, Misdemeanor_yn,
                    Felony_yn, comment, DoNotRehire, Address, City, State, Zip, Phone, EMail, Volunteer, Disconnected, UpdatedBy, UpdatedOn, StudentTeacher, STA,
                    JRE, MVCS, IA, StudentTeacherCDE)
        VALUES		('#Session.FPID#', '#Session.LName#', '#Session.FName#', '#Session.SSN#', '#Session.FLName#', 
        			'#Session.DOB#', '#Session.FPDate#', '#Session.FPUnread#', '#Session.Attachment#', '#Session.Undetermined#',
                    '#Session.Misdemeanor#', '#Session.Felony#', '#Session.Comments#', '#Session.DoNotRehire#', '#Session.Address#', 
                    '#Session.City#', '#Session.State#', '#Session.Zip#', '#Session.Phone#', '#Session.Email#',
                    '#Session.Volunteer#', '#Session.Disconnected#', '#Session.UpdatedBy#', '#Session.UpdatedOn#', '#Session.StuTeach#', '#Session.STA#',
                    '#Session.JRE#','#Session.MVCS#','#Session.IA#','#Session.StuTeachCDE#')
    </cfquery>

    <!--- Log Inserting New Data --->
    <cfquery name="LogInsert" datasource="hrinfopath">
        INSERT INTO tblFingerPrint_LogInfo
            (DateTime, LogInfo, IPAddress, FPUser)    
        VALUES
            (
                <cfqueryparam value="#NOW()#" cfsqltype="cf_sql_timestamp">,
                <cfqueryparam value="Inserting New Data - FAPID: #Session.FPID#" cfsqltype="cf_sql_varchar" >,
                <cfqueryparam value="#CGI.REMOTE_ADDR#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="MESA\#Session.Username#" cfsqltype="cf_sql_varchar">
            )
    </cfquery>
    
    <!--- if attachment go to Step 30 --->
    <cfif #Session.Attachment# eq 'Y'>
    	<cflocation url="index.cfm?StepNum=30">
    </cfif>
    
    <!--- return to menu --->
	<cflocation url="index.cfm?StepNum=1">
<!--- Log Out --->
<cfelseif url.StepNum eq 999>
	<!---<cfcookie name="CFID" expires="now">
	<cfcookie name="CFTOKEN" expires="now">--->
	<cfscript>
   		StructClear(Session);
	</cfscript>
	<cflocation url="https://intranet.mesa.k12.co.us/2003/apps/FingerPrint/index.cfm">
<!--- End of Steps --->
</cfif>
   			<!-- InstanceEndEditable -->
     </main>        	
  	</div>
	 	<br class="clearfloat" />
  	<div id="footer" class="noprint">
    <footer>
  	<cfinclude template="/2003/templates/components/footer.cfm">
    </footer>
  </div>
</div>
</div>
  <!-- end #footer -->

<!-- end #container -->

</body>
<!-- InstanceEnd --></html>