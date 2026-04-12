<?php
namespace App\Library;

class Message
{
    private $message;

    public function __construct(String $message = '')
    {
        $this->message = $message;
    }

    public function login($otp)
    {
        
        return ($this->message != '') ? $this->message : " $otp is the OTP for OPAN Login/Register. OTP is valid for 5 Minutes. Do not share this OTP with anyone" ;
    }


    public function forget_password($otp, String $name = 'User')
    {

        return ($this->message != '') ? $this->message : " $otp is the OTP for OPAN Login/Register. OTP is valid for 5 Minutes. Do not share this OTP with anyone" ;
    }

    public function fund_transfer($amount, $reason='direct fund transfer', $time = '', $type='Credit')
    {
        $type = ($type == 'Credit') ? 'Credited To' : 'Debited Form' ;

        $time = ($time != '') ? date("d-m-y", strtotime($time)) : date('d-m-y');

        return ($this->message != '') ? $this->message : " $amount is $type your OPAN Wallet on $time for $reason. Call on +919479075980 For Dispute this Transaction. Thanks & Regards, TEAM OPAN." ;
    }

    public function add_money($amount, $whatfor='Added To', $datetime = '')
    {
        $datetime = ($datetime != '') ? date("d-m-y h:i a", strtotime($datetime)) : date('d-m-y h:i a');

        return ($this->message != '') ? $this->message : "$amount is $whatfor your OPAN Wallet at $datetime. Call on +919479075980 For Dispute this Transaction. Thanks & Regards, TEAM OPAN" ;
    }

    public function withdrawl_request($amount, $datetime = '')
    {
        $datetime = ($datetime != '') ? date("d-m-y h:i a", strtotime($datetime)) : date('d-m-y h:i a');

        return ($this->message != '') ? $this->message : " $amount Withdrawl Request is created at $datetime From OPAN Wallet. Call on +919479075980 For Dispute this Transaction. Thanks & Regards, TEAM OPAN" ;
    }

    public function withdrawl_approve($amount, $datetime = '')
    {
        $datetime = ($datetime != '') ? date("d-m-y h:i a", strtotime($datetime)) : date('d-m-y h:i a');

        return ($this->message != '') ? $this->message : " $amount Withdrawal Request is approved at $datetime From OPAN Wallet. Call on +919479075980 For Dispute this Transaction. Thanks & Regards, TEAM OPAN" ;
    }
}
