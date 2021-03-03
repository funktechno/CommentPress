<?php
session_start();
$action = filter_input(INPUT_POST, 'action');
if ($action == NULL) {
    $action = filter_input(INPUT_GET, 'action');
}
$GLOBALS['root'] = "../";
// Get the database connection file
require_once '../library/connections.php';
require_once '../library/functions.php';
require_once '../model/reviews-model.php';
require_once '../library/error_responses.php';
header("Access-Control-Allow-Origin: " . Allowed_Origins);
header("Access-Control-Allow-Methods: " . Allowed_Methods);
header("Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept");
header('Content-type: application/json');

$errorStatus = App\errorStatus::getInstance();
$input = json_decode(file_get_contents('php://input'), true);
if (!isset($input)) // if null then set to $_POST for simple posts
{
    $input = $_POST;
}

$directoryURI = $_SERVER['REQUEST_URI'];
switch ($action) {
    case 'mod':
        $userId = $input['userId'];
        $id = $input['id'];

        if (empty($userId) || empty($id)) {
            $errorStatus->response(400, "comment id field is required");
        }

        $comment = getComment($id);
        if (!isset($comment['id'])) {
            $errorStatus->response(404, "Comment doesn't exist.");
        }

        break;
    case 'del':
        $userId = $input['userId'];
        $id = $input['id'];
        $body = $input['body'];

        if (empty($userId) || empty($id) || empty($body)) {
            $errorStatus->response(400, "comment id and body fields are required");
        }

        $comment = getComment($id);
        if (!isset($comment['id'])) {
            $errorStatus->response(404, "Comment doesn't exist.");
        }

        break;
    case 'get':
        $slug = $input['slug'];
        if (empty($slug)) {
            $errorStatus->response(400, "page slug field is required");
        }
        $comments = getPageComments($slug);
        // recursively updated comments w/ child comments

        echo json_encode($comments);

        break;
    case 'submit':
        // todo retrieve from jwt
        $userId = $input['userId'];

        $slug = $input['slug'];
        // $pageId = $input['pageId'];
        $parentId = $input['parentId'];
        $body = $input['body'];

        if (empty($userId) || empty($slug) || empty($body)) {
            $errorStatus->response(400, "page slug and body fields are required");
        }

        if (empty($parentId)) {
            $parentId = null;
        }


        // check if page locked
        $pageData = getPageStatus($slug);
        // if manual pages enabled then don't auto create page if it doesn't exist
        if (
            isset($pageData['manualPages']) &&
            $pageData['manualPages'] == 'true' &&
            !isset($pageData['id'])
        ) {
            $errorStatus->response(400, "Page doesn't exist.");
        }

        if (!isset($pageData['id'])) {
            // create page
            $newRecord = createPage($slug);
            if ($newRecord == 1) {
                $pageData = getPageStatus($slug);
            } else {
                $errorStatus->response(500, "Failed to auto create missing page.");
            }
        }

        if (isset($pageData['lockedComments']) && $pageData['lockedComments'] = 1) {
            $errorStatus->response(403, "Comments are locked on this page.");
        }
        // if not unlimited and parentid passed check existing comment if it has a parent id
        if (
            isset($parentId)
        ) {
            // echo $parentId;
            // grab comment and check that it doesn't have a parent id
            $parentComment = getComment($parentId);
            if (!isset($parentComment['id'])) {
                $errorStatus->response(404, "Parent comment doesn't exist.");
            }
            // check that pageid matches
            if ($parentComment['pageId'] != $pageData['id']) {
                $errorStatus->response(400, "Parent comment must be of the same page.");
            }
            if ((!isset($pageData['unlimitedReplies']) ||
                $pageData['unlimitedReplies'] != 'true')) {
                if (isset($parentComment['parentId'])) {
                    $errorStatus->response(400, "Unlimited replies are disabled. Only one level reply is permitted.");
                }
            }
        }
        $regOutcome = createComment($userId, $pageData['id'], $parentId, $body);
        if ($regOutcome === 1) {

            $statuscode = 201;

            header("HTTP/1.1 " . $statuscode);

            $response = array('Status' => 'success');

            echo json_encode($response);
        } else {
            $errorStatus->response(500, "Error saving message");
        }

        break;
    case 'moderate':
        include '../view/commentModeration.php';

        break;
    default;
        // header('location: /accounts/');
        $errorStatus->response(404, "Method not valid");
        // include '../view/admin.php';
        break;
        // include '../view/404.php';
}
