
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head><title>
	SIRE Public Access
</title><meta content="Microsoft Visual Studio .NET 7.1" name="GENERATOR"><meta content="Visual Basic .NET 7.1" name="CODE_LANGUAGE"><meta content="JavaScript" name="vs_defaultClientScript"><meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema"><link href="Styles.css" type="text/css" rel="stylesheet" />
		<script type="text/javascript" src="JS/jquery.min.js"></script>
		<script type="text/javascript" src="JS/jquery-ui.min.js"></script>
		<script type="text/javascript" src="JS/dialog.js"></script>
		<script type="text/javascript">
			function LoadFirst(){
				try{
					if (Form1.MediaPlayerPosition.value != ""){
						parent.setMediaPlayerPosition(Form1.MediaPlayerPosition.value);
					}
				}catch (ex){}
			}
			function ShowMoDialog(url, width, height, title) {
			    SetCommentPage(url);
			    ( typeof parent != 'undefined' && parent != self ? parent : self ).ShowModalDialog(url, width, height, title, querySt("itemid"));
			}
			function querySt(ji) {
				var re = new RegExp(/(?:\?|&)([^=#]+?)(?:=([^&#]+))/ig);
				var rs = null;
				while ((rs = re.exec(window.location.href)) != null) {
					if (ji.toLowerCase() == rs[1].toLowerCase()) {
						return rs[2];
					}
				}
				return null;
			}
			function showViewer(obj, isMobile) {
				return false;
			}
		</script>
	<link href="templates/Classic/Styles.css" rel="stylesheet" type="text/css" /></head>
	<body class="lightblue" style="margin:0;" onload="javascript:LoadFirst()">
		<form name="Form1" method="post" action="agdocs.aspx?doctype=agenda&amp;itemid=40268" id="Form1">
<input type="hidden" name="__VIEWSTATE" id="__VIEWSTATE" value="/wEPDwUKLTY5Mzg1OTk2MA9kFgICAw9kFgYCBQ8WAh4HVmlzaWJsZWdkAgsPDxYCHgRUZXh0BVxBcHByb3ZlIGFuIG9yZGluYW5jZSByZWxhdGluZyB0byBjb3VuY2lsIG1lZXRpbmcgcHJvY2VkdXJlcyBhbmQgY291bmNpbCBjb21taXR0ZWUgc3RydWN0dXJlLmRkAhEPDxYEHgdFbmFibGVkaB8AaGRkZLKGC5EOJx9pXn5zGr8y6K0daCZM4IA71jUUEUnFwDYF" />

<input type="hidden" name="__EVENTVALIDATION" id="__EVENTVALIDATION" value="/wEWAwKLk62VAQKV88H1CwLHtdT7DRxtfQhpB6ZVfb/oOQgyqh4dX8PLxbv6bVvgPtQNvMIN" />
			
			
			<table id="ShareTable" width="100%" border="0" style="border-bottom: solid gray 1px;">
	<tr>
		<td>
						<span id="Label2" class="header">Share</span>    
					</td>
	</tr>
	<tr>
		<td>
						<span id="Label3" class="normal">To share this item click the button below:</span>    
					</td>
	</tr>
	<tr>
		<td style="height: 27px">
						<input name="ShareUrl" type="hidden" id="ShareUrl" value="share.aspx?meetid=652&amp;doctype=agenda&amp;itemid=40268" />
						 <input type="button" id="btnShare" class="ImageButton" style="background-image: url(Images/text.gif); width: 72px;" value="Share" onclick="ShowMoDialog(document.getElementById('ShareUrl').value,550,400,'Share')" />    
					</td>
	</tr>
	<tr style="height: 15px;">
		<td style="height: 15px"></td>
	</tr>
</table>

			
			<table id="Table1" width="100%" border="0" style="border-bottom: solid gray 1px;">
				<tr>
					<td><span id="Label1" class="header">Supporting Materials</span></td>
				</tr>
				<tr>
					<td><span id="lblTitle" class="normal">Approve an ordinance relating to council meeting procedures and council committee structure.</span></td>
				</tr>
				<tr>
					<td><table id="tblMaterials" class="regtable" border="0" width="100%">
	<tr>
		<td class="tableheader" width="100%">Files</td>
	</tr><tr>
		<td class="tabledata"><a onclick="return !showViewer(this,false);" href="view.aspx?cabinet=published_meetings&fileid=940453" target=parent><img src="images/pdf.gif" border="0" alt="PDF Document"></a>&nbsp;&nbsp;Approve an ordinance relating to council meeting p - IFC.doc</td>
	</tr><tr>
		<td class="tabledata"><a onclick="return !showViewer(this,false);" href="view.aspx?cabinet=published_meetings&fileid=940454" target=parent><img src="images/pdf.gif" border="0" alt="PDF Document"></a>&nbsp;&nbsp;Approve an ordinance relating to council meeting p - Revised Draft Ordinance.pdf</td>
	</tr><tr>
		<td class="tabledata"><a onclick="return !showViewer(this,false);" href="view.aspx?cabinet=published_meetings&fileid=940455" target=parent><img src="images/pdf.gif" border="0" alt="PDF Document"></a>&nbsp;&nbsp;Approve an ordinance relating to council meeting p - Revised Draft Ordinance (Redlined).pdf</td>
	</tr><tr>
		<td class="tabledata"><a onclick="return !showViewer(this,false);" href="view.aspx?cabinet=published_meetings&fileid=940456" target=parent><img src="images/pdf.gif" border="0" alt="PDF Document"></a>&nbsp;&nbsp;Approve an ordinance relating to council meeting p - Memo (New Committee Structure FY 15)</td>
	</tr>
</table>
						<table id="VideoTable" class="regtable" border="0" width="100%">

</table>  
						
					</td>
				</tr>
				<tr>
					<td></td>
				</tr>
			</table>
			<span id="lblConfidential"></span>
			<input name="MediaPlayerPosition" type="hidden" id="MediaPlayerPosition" />
			            
		</form>
	</body>
</html>
