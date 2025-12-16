<?php
$_POST['email'] = 'antacursor@gmail.com';
$_POST['otp'] = '12345';
$_SERVER['REQUEST_METHOD'] = 'POST';

include 'send-otp-gmail.php';
