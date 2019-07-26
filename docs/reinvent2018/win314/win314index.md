![](/images/reinvent_black.png)
#Welcome to WIN314 - Modernize Your First Windows Application with Windows Containers

**Our builder session will begin with a short presentation on how to containerize .NET applications on AWS. You will then have the opportunity to build a Docker container for a sample .NET application and deploy that container/application to Amazon Elastic Container Service (ECS).**

<br />
We have created a temporary AWS account for you to use during this builder session. The account has the running EC2 Windows Server already configured with the tools needed to run this session. Enter the code given to you by your instructor to retrieve your console access URL, username/password and AWS keys. We'll use these to log in to your temporary AWS account.


<div>
<label>Code:<input id="code" name="code" onkeydown="handleKey(event)" size="10" style="padding:2px;margin:4px;font-size: 16px;border-bottom: 1px solid black;" type="text"/><input name="Go" onclick="showCredentials(this)" style="font-size: 16px;font-weight:bold;border: 1px solid black;" type="submit" value="Go!"/></label>
<script type="text/javascript">
    function handleKey(event) {
        event.stopPropagation();
    }
    function showCredentials(el) {
        var codeInput = document.getElementById('code');
        var code = codeInput.value;
        var win = window.open("https://cj31tpwxr8.execute-api.us-east-2.amazonaws.com/Prod/api/values/" + code, '_blank');
        win.focus();
      }
</script>
</div>

<br />
Let's get started! (click next below)
<br />
<br />