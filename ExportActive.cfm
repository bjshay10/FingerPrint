<!--- Export Active data for Finger Print DB 
		Create On 12/09/11
		By: B.J. Shay 
		Modification:
		12/09/11 - BJS - Initial Creation 
		12/03/14 - BJS - Added StudentTeacher --->
		
<!--- use cfsetting to block output of HTML outside of cfoutput tags --->
<cfsetting enablecfoutputonly="Yes">

<!--- Query Data --->
<cfquery name="GetFPData" datasource="hrinfopath">
	SELECT     FPID, LName, FName, SSN, FormerLName, DOB, FPDate, FPUnRead, Attachment_yn, Undetermined_yn, Misdemeanor_yn, Felony_yn, Comment, DoNotRehire, Address, 
                      City, State, Zip, Phone, EMail, Volunteer, UpdatedBy, UpdatedOn, StudentTeacher, STA, StudentTeacherCDE
	FROM       tblFingerPrintDB
    WHERE		Disconnected <> 'on' or Disconnected IS NULL
</cfquery>

	<cfset delim = chr(9)>
	<cfset NewLine = Chr(13) & Chr(10)>
	<cfset HeaderLine = "FPID"&#delim#&"Last Name"&#delim#&"First Name"&#delim#&"SSN"&#delim#&"Former Last Name"&#delim#&"DOB"&#delim#&"Finger Print Date"&#delim#&"Finger Print Unreadable"&#delim#&"Attachments y/n"&#delim#&"Undetermined y/n"&#delim#&"Misdemeanor y/n"&#delim#&"Felony y/n"&#delim#&"Comment"&#delim#&"Do Not Rehire y/n"&#delim#&"Address"&#delim#&"city"&#delim#&"State"&#delim#&"Zip"&#delim#&"Phone"&#delim#&"Email"&#delim#&"Volunteer y/n"&#delim#&"Student Teacher (FP with D51)"&#delim#&"Student Teacher (FP With CDE)"&#delim#&"STA"&#delim#&"UpdatedBy"&#delim#&"UpdatedOn"&#NewLine#>
    
<cfsavecontent variable="sFileContent">
<cfoutput>#HeaderLine#</cfoutput>

<cfloop query="GetFPData">
<cfoutput>#FPID##delim##LName##delim##Fname##delim##SSN##delim##FormerLName##delim##LSDateFormat(DOB, 'mm/dd/yyyy')##delim##LSDateFormat(FPDate, 'mm/dd/yyyy')##delim##FPUnRead##delim##Attachment_yn##delim##Undetermined_yn##delim##Misdemeanor_yn##delim##Felony_yn##delim##Comment##delim##DoNotRehire##delim##Address##delim##City##delim##State##delim##Zip##delim##Phone##delim##Email##delim##Volunteer##delim##StudentTeacher##delim##StudentTeacherCDE##delim##STA##delim##UpdatedBy##delim##LSDateFormat(UpdatedOn, 'mm/dd/yyyy')##NewLine#</cfoutput>
</cfloop>

</cfsavecontent>

<cfheader name="Content-Disposition" value="attachment;filename=FingerPrint_ActivesData.xls">
 	
<cfcontent type="application/vnd.ms-excel"><cfoutput>#sFileContent#</cfoutput>