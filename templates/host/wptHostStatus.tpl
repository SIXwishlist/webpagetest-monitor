<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    {include file="headIncludes.tpl"}
    <title>Status</title>
</head>
<body>
<div class="page">
    {include file='header.tpl'}
    {include file='navbar.tpl'}
    <div id="main">
        <div class="level_2">
            <div class="content-wrap">
                <div class="content" style="height:auto; overflow:auto;width:inherit;">
                    <br>
                    <h2 class="cufon-dincond_black">Queue Status</h2>
                    <table class="pretty" style="border-collapse:collapse" width="100%">
                        <thead>
                        <tr>
                            <th align="left">Host</th>
                            <th align="left">ID</th>
                            <th align="left">Label</th>
                            <th align="left">Browser</th>
                            <th>Active Jobs</th>
                            <th align="right">Run Rate *</th>
                            <th align="right">Testers</th>
                            <th align="right">In Queue</th>
                            <th align="right">High</th>
                            <th align="right">Low</th>
                            <th></th>
                        </tr>
                        </thead>
                        {assign var="eo" value="odd"}
                        {foreach from=$locations item=location}
                            {if $eo == "even"} {assign var="eo" value="odd"} {else} {assign var="eo" value= "even"}{/if}
                            {assign value="#98fb98" var="bgcolor"}
                            {if $location.PendingTests > $location.GreenLimit}{assign value="yellow" var=bgcolor}{/if}
                            {if $location.PendingTests > $location.YellowLimit}{assign value="red" var=bgcolor}{/if}
                            <tr class="{$eo}">
                                <td>{$location.host}</td>
                                <td><a href="#{$location.id}">{$location.id}</a></td>
                                <td>{$location.Label}</td>
                                <td>{$location.Browser}</td>
                                <td align="center">{$location.activeJobs|default:''}</td>
                                <td align="center">{if isset($location.runRate)}{$location.runRate|number_format}{/if}</td>
                                <td align="center">{$location.AgentCount}</td>
                                <td align="center">{$location.PendingTests}</td>
                                <td align="center">{$location.PendingTestsHighPriority}</td>
                                <td align="center">{$location.PendingTestsLowPriority}</td>
                                <td style="opacity:0.6;background-color:{$bgcolor}"></td>
                            </tr>
                        {/foreach}
                    </table>
                    <br>
                    {if $delayedLocationsAggregated}
                        <h2>Queue Delays</h2>
                        <table class="pretty">
                            <thead>
                            <tr>
                                <th>Location</th>
                                <th>Agent</th>
                                <th>#jobs</th>
                                <th>Maximum delay<br>of job</th>
                                <th></th>
                            </tr>
                            </thead>
                            <tbody>
                            {foreach from=$delayedLocationsAggregated item=delayedLocation}
                                {if $eo == "even"} {assign var="eo" value="odd"} {else} {assign var="eo" value= "even"}{/if}
                                {assign value="#98fb98" var="bgcolor"}
                                {if $delayedLocation.MaximumDelay > 60}{assign value="yellow" var=bgcolor}{/if}
                                {if $delayedLocation.MaximumDelay > 300}{assign value="red" var=bgcolor}{/if}
                                <tr class="{$eo}">
                                    <td>{$delayedLocation.Location}</td>
                                    <td>{$delayedLocation.Agent}</td>
                                    <td style="text-align: center">{$delayedLocation.NumberOfJobs}</td>
                                    <td style="text-align: right">{$delayedLocation.MaximumDelay|time_difference}</td>
                                    <td style="opacity:0.6;background-color:{$bgcolor}"></td>
                                </tr>
                            {/foreach}
                            </tbody>
                        </table>
                        <br>
                    {/if}
                    <br>
                    <h2 class="cufon-dincond_black">Tester Status</h2>
                    <table class="pretty" style="border-collapse:collapse" width="100%">
                        <thead>
                        <tr>
                            <th></th>
                            <th align="right">Tester</th>
                            <th align="center">PC</th>
                            <th align="right">EC2 Instance</th>
                            <th align="center">Launch Time</th>
                            <th align="center">
                                <a title="EC2 State as of last query">EC2 State</a>
                                (<a href="?cache=false">refresh</a>)
                                <br>
                                ({$lastEc2StatusCheck|date_format:"Y/m/d - H:i:s"})
                            </th>
                            <th align="center">IP</th>
                            <th align="right">Busy</th>
                            <th align="right">Last Check</th>
                            <th align="right">Last Work</th>
                        </tr>
                        </thead>
                        {foreach from=$testers item=tester}
                            <tr>
                                <td colspan="10" nowrap="nowrap" bgcolor="#f5f5dc">
                                    <h4 style="font-size: medium;">
                                        <a name="{$tester.id}"></a>{$tester.id}
                                    </h4>
                                </td>
                            </tr>
                            {assign var="eo" value="odd"}
                            {foreach from=$tester.Agents item=agent}
                                {if $eo == "even"} {assign var="eo" value="odd"} {else} {assign var="eo" value= "even"}{/if}
                                {assign value="#98fb98" var="bgcolor"}

                                <tr class="{$eo}">
                                    <td></td>
                                    <td align="right">{$agent.index}</td>
                                    <td align="center">{$agent.pc}</td>
                                    <td align="center">{$agent.ec2}</td>
                                    <td align="center">{if isset($agent.ec2Status.launchTime)}{$agent.ec2Status.launchTime}{/if}</td>
                                    <td align="center">{if isset($agent.ec2Status.state)}{$agent.ec2Status.state}{/if}</td>
                                    <td align="center">{$agent.ip}</td>
                                    <td align="right">{$agent.busy}</td>
                                    <td align="right">{$agent.elapsed}</td>
                                    <td align="right">{$agent.last}</td>
                                </tr>
                            {/foreach}
                        {/foreach}
                    </table>
                    <br>
                    <h2 class="cufon-dincond_black">User Status</h2>
                    <table class="pretty" style="border-collapse::collapse" width="100%">
                        <thead>
                        <tr>
                            <th align="left">Username</th>
                            <th align="right">Jobs</th>
                            <th align="right">Active Jobs</th>
                            <th align="right">Run Rate *</th>
                        </tr>
                        </thead>
                        {assign var="eo" value="odd"}
                        {*{foreach $runRateInfo.runRatePerUser as $user=>$runRate}*}
                        {foreach $runRateInfo.users as $user}
                            {if $eo == "even"} {assign var="eo" value="odd"} {else} {assign var="eo" value= "even"}{/if}
                            {assign value="#98fb98" var="bgcolor"}
                            <tr class="{$eo}">
                                <td nowrap="nowrap">{$user}</td>
                                <td align="right">{if isset($runRateInfo.jobsPerUser[$user])}{$runRateInfo.jobsPerUser[$user]}{else}0{/if}</td>
                                <td align="right">{if isset($runRateInfo.activeJobsPerUser[$user])}{$runRateInfo.activeJobsPerUser[$user]}{else}0{/if}</td>
                                <td align="right" nowrap="nowrap">{if isset($runRateInfo.runRatePerUser[$user])}{$runRateInfo.runRatePerUser[$user]|number_format}{else}0{/if}</td>
                            </tr>
                        {/foreach}
                        <tr>
                            <td colspan="4">
                                <hr>
                            </td>
                        </tr>
                        <tr class="even" style="font-weight:bold;">
                            <td align="right">Total</td>
                            <td align="right">{$runRateInfo.totalJobs}</td>
                            <td align="right" nowrap="nowrap">{$runRateInfo.totalActiveJobs}</td>
                            <td align="right" nowrap="nowrap">{$runRateInfo.hourlyRunRate}</td>
                        </tr>
                    </table>
                    <br>

                    <h4>* Run rates are per hour.</h4>
                </div>
            </div>
        </div>
    </div>
</div>
<script type="text/javascript">
    $(function(){
        setTimeout(function(){
            location.href = location.href + "";
        },60000);
    })
</script>
</body>
</html>
