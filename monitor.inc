<?php
require_once( 'bootstrap.php' );
if(!isset( $_SESSION )) {
    session_start();
}
if(!array_key_exists('ls_timezone', $_SESSION)) {
    $_SESSION['ls_timezone'] = 'GMT';
}
date_default_timezone_set($_SESSION['ls_timezone']);

try{
    // when calling install.php and database does not exists yet, Doctrine throws an exception
    $dataConn->execute("SET time_zone = '" . $_SESSION['ls_timezone'] . "'");
} catch(Exception $e){
    //TODO: Handle exception in an acceptable way
    trigger_error('Error during setting time_zone: "' . $e->getMessage() . '"');
}

// Check to see if we are to impersonate
if(array_key_exists('impId', $_REQUEST) && array_key_exists('ls_admin', $_SESSION)) {
    $_SESSION['ls_impersonate_id'] = $_REQUEST['impId'];
    // Clear session vars
    foreach ($_SESSION as $key => $sessionVar) {
        // Skip the ls_ vars
        if(stripos($key, "ls_")>-1) {
            continue;
        }
        unset( $_SESSION[$key] );
    }
}
//  date_default_timezone_set($_SESSION['ls_timezone']);
$baseDir = dirname(__FILE__);
//  $wptHost="http://wpt.mtvly.com";
$wptRuntest    = "/runtest.php";
$wptResult     = "/result/";
$wptXmlResult  = "/xmlResult/";
$wptResultsDir = dirname(__FILE__) . "/wpt_results/";

require( $baseDir . '/lib/Smarty-3.0.6/libs/Smarty.class.php' );
require_once( 'smartyPlugins.inc' );

// create object
$smarty                = new Smarty;
$smarty->template_dir  = 'templates';
$smarty->compile_dir   = 'templates_c';
$smarty->allow_php_tag = true;

// Setup Permissions
//  $smarty->assign('hasPermission',hasPermission);
define( "PERMISSION_READ", 0 );
define( "PERMISSION_UPDATE", 1 );
define( "PERMISSION_CREATE_DELETE", 2 );
define( "PERMISSION_EXECUTE", 4 );
define( "PERMISSION_OWNER", 9 );

$tableNameLabel               = array();
$tableNameLabel['WPTJob']     = "Job";
$tableNameLabel['WPTScript']  = "Script";
$tableNameLabel['Alert']      = "Alert";
$tableNameLabel['ChangeNote'] = "ChangeNote";

$wptResultStatusCodes               = array();
$wptResultStatusCodes['-214669721'] = "Failed to connect";
$wptResultStatusCodes['100']        = "Pending";
$wptResultStatusCodes['200']        = "Complete";
$wptResultStatusCodes['404']        = "HTTP 404";
$wptResultStatusCodes['407']        = "HTTP 407";
$wptResultStatusCodes['500']        = "HTTP 500";
$wptResultStatusCodes['503']        = "HTTP 503";
$wptResultStatusCodes['900']        = "Timeout";
$wptResultStatusCodes['905']        = "Job Submission Failed";
$wptResultStatusCodes['910']        = "Max Download Attempts Exceeded";
$wptResultStatusCodes['990']        = "X-SL-CompState: Uncompiled";
$wptResultStatusCodes['999']        = "Test data missing";
$wptResultStatusCodes['99996']      = "Test Failed waiting for specified DOM element/End condition";
$wptResultStatusCodes['99997']      = "Test Timed Out (no content errors)";
$wptResultStatusCodes['99998']      = "Test Timed Out (content errors)";
$wptResultStatusCodes['99999']      = "Individual requests failed";

$wptValidationStateCodes['1'] = "Valid";
$wptValidationStateCodes['2'] = "Invalid";
$wptValidationStateCodes['3'] = "Needs Review";

// Results per page
if($_SESSION) {
    if(!array_key_exists('resultsPerPage', $_SESSION)) {
        $_SESSION['resultsPerPage'] = 15;
    }
}
if(array_key_exists('resultsPerPage', $_REQUEST)) {
    $_SESSION['resultsPerPage'] = $_REQUEST['resultsPerPage'];
}
// Handle results per page
$resultsPerPage = $_SESSION['resultsPerPage'];
$smarty->assign('resultsPerPage', $_SESSION['resultsPerPage']);

define( "VALIDATION_TYPE_MATCH", 1 );
define( "VALIDATION_TYPE_NOMATCH", 2 );
define( "VALIDATION_STATE_VALID", 1 );
define( "VALIDATION_STATE_INVALID", 2 );
define( "VALIDATION_STATE_NEEDS_REVIEW", 3 );
define( "TARGET_RUN_RATE_RATIO", 150 );
define( "EC2_MAXIMUM_INSTANCES_PER_REGION", 20 );
define( "EC2_MAXIMUM_SPOT_PRICE", 0.15 );
define( "EC2_USER_DATA", 'wpt_server=wptm.strangeloopnetworks.com wpt_key=slfast wpt_timeout=120' );