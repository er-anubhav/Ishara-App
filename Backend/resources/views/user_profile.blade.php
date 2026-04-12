<!DOCTYPE html>

<html class="loading" lang="en" data-textdirection="ltr">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0">
    <title>Profile - 888Playwin</title>
@include('admin.layout.header')
<style>
.level-select {
  appearance: none;
  background-color: transparent;
  border: none;
  padding: 0 1em 0 0;
  margin: 0;
  width: fit-content;
  max-width: 30ch;
  border: 1px solid grey;
  border-radius: 0.25em;
  padding: 0.25em 0.5em;
  font-size: 1.15rem;
  cursor: pointer;
  line-height: 1.1;
  outline: none;

}
#LoanTable_length, #LoanTable_filter, #TansactionTable_length, #TansactionTable_filter{
  display: none;
}

</style>
    <!-- BEGIN: Content-->
    <div class="app-content content">
      <div class="content-overlay"></div>
      <div class="content-wrapper">
        <div class="content-header row">
        </div>
        <div class="content-body"><!-- users view start -->
<section class="users-view">
  <!-- users view media object start -->
  <div class="row  mt-1">
    <div class="col-12 col-sm-7">
      <div class="media mb-2">
        <a class="mr-1" href="javascript:void(0);">
          @if($user->profile_picture != NULL)
          <img src="{{url('app-assets/images/portrait/small/avatar-s-11.png')}}" alt="users view avatar" class="users-avatar-shadow rounded-circle" height="64" width="64">
          @else
          <img src="{{url('app-assets/images/portrait/small/avatar-s-11.png')}}" alt="users view avatar" class="users-avatar-shadow rounded-circle" height="64" width="64">
          @endif
        </a>
        <div class="media-body pt-25">
          <h4 class="media-heading"><span class="users-view-name">{{$user->name}} </span></h4>
          <span>Phone:</span>
          <span class="users-view-id">{{$user->phone}}</span>
        </div>
      </div>
    </div>
  </div>
  <!-- users view media object ends -->
  <!-- users view card data start -->
  <div class="card">
    <div class="card-body pb-0">
      <div class="row">
        <div class="col-12 col-md-4">
          <table class="table table-borderless">
            <tbody>
              <tr>
                <td>Registered:</td>
                <td>{{date("d-m-Y", strtotime($user->created_at))}}</td>
              </tr>
              <tr>
                <td>Balance:</td>
                <td class="users-view-latest-activity" style="color:green;">₹ {{$user->balance}}</td>
              </tr>
              <tr>
                <td>Role:</td>
                <td class="users-view-role">User</td>
              </tr>
              <tr>
                <td>Status:</td>
                <td>

                  @if($user->is_active == 'Yes')
                  <span class="badge badge-light-success">Active</span>
                  @else
                  <span class="badge badge-light-danger">In-Active</span>
                  @endif
                  
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="col-12 col-md-8">
          <!-- Nav Filled Starts -->
<section id="nav-filled">
  <div class="row">
    
    <div class="col-sm-12">
      <div class="card">
        <div class="card-body p-0">
          <!-- Nav tabs -->
          <ul class="nav nav-tabs nav-fill" id="myTab" role="tablist">
            <li class="nav-item">
              <a class="nav-link active" id="basic-tab-fill" data-toggle="tab" href="#basic-fill" role="tab"
                aria-controls="basic-fill" aria-selected="true">
                Basic
              </a>
            </li>
            <li class="nav-item">
              <a class="nav-link" id="bank-account-tab-fill" data-toggle="tab" href="#bank-account-fill" role="tab"
                aria-controls="bank-account-fill" aria-selected="false">
                Bank Account
              </a>
            </li>
          </ul>

          <!-- Tab panes -->
          <div class="tab-content">
            <div class="tab-pane active" id="basic-fill" role="tabpanel" aria-labelledby="basic-tab-fill">
              <table class="table table-borderless">
                <tbody>
                  <tr>
                    <td>Email:</td>
                    <td>{{$user->email}}</td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div class="tab-pane" id="bank-account-fill" role="tabpanel" aria-labelledby="bank-account-tab-fill">
              @if(isset($payment_account->bank_account))
                <table class="table table-borderless">
                <tbody>
                  <tr>
                    <td>Beneficiary:</td>
                    <td>{{$payment_account->bank_account['beneficiary']}}</td>
                  </tr>
                  <tr>
                    <td>IFSC:</td>
                    <td class="users-view-latest-activity">{{$payment_account->bank_account['ifsc']}}</td>
                  </tr>
                  <tr>
                    <td>Bank:</td>
                    <td class="users-view-latest-activity">{{$payment_account->bank_account['bank']}}</td>
                  </tr>
                  <tr>
                    <td>A/c:</td>
                    <td>{{$payment_account->bank_account['number']}}</td>
                  </tr>
                </tbody>
              </table>
              @endif
              @if(isset($payment_account->upi))
                <table class="table table-borderless">
                <tbody>
                  <tr>
                    <td>UPI:</td>
                    <td>{{$payment_account->upi}}</td>
                  </tr>
                </tbody>
              </table>
              @endif
            </div>
            
          </div>
        </div>
      </div>
    </div>
  </div>
</section>
<!-- Nav Filled Ends -->
        </div>
      </div>
    </div>
  </div>
  <!-- users view card data ends -->
  <!-- users view card details start -->
  <div class="card">
    <div class="card-body">
      <div class="row bg-primary bg-lighten-5 rounded mb-2 mx-25 text-center text-lg-left">
        <div class="col-12 col-sm-4 p-2">
          <h6 class="text-primary mb-0">Withdrawal Request's: <span class="font-large-1 align-middle">{{$user->withdrawal_requests}}</span></h6>
        </div>
        <div class="col-12 col-sm-4 p-2">
          <h6 class="text-primary mb-0">Accepted: <span class="font-large-1 align-middle">{{$user->withdrawal_accepted}}</span></h6>
        </div>
        <div class="col-12 col-sm-4 p-2">
          <h6 class="text-primary mb-0">Rejected: <span class="font-large-1 align-middle">{{$user->withdrawal_rejected}}</span></h6>
        </div>
      </div>
      <div class="col-12">
        <h3 class="mb-1"><i class="bx bx-link"></i>Withdrawal Request</h3>
        <div class="table-responsive">
          <table id="WithdrawalTable" class="table " style="width: 100%;">
              <thead>
                  <tr>
                      <th>Request ID</th>
                      <th>Bank Detalis</th>
                      <th>Requested At</th>
                      <th>Amount</th>
                      <th>Payout Id</th>
                      <th>Status</th>
                  </tr>
              </thead>
              <tbody>
            
              </tbody>
          </table>
        </div>
        <h3 class="mb-1"><i class="bx bx-info-circle"></i> Tansactions</h3>
        <div class="table-responsive">
          <table id="TransactionTable" class="table " style="width: 100%;">
              <thead>
                  <tr>
                      <th>Transaction ID</th>
                      <th>Amount(₹)</th>
                      <th>Trasaction At</th>
                      <th>Type</th>
                      <th>Status</th>
                  </tr>
              </thead>
              <tbody>
            
              </tbody>
          </table>
        </div>
        <h3 class="mb-1"><i class="bx bx-info-circle"></i> Biddings</h3>
        <div class="table-responsive">
          <table id="BiddingTable" class="table " style="width: 100%;">
              <thead>
                  <tr>
                      <th>Name</th>
                      <th>Type</th>
                      <th>Date</th>
                      <th>Result Time</th>
                      <th>Biddings</th>
                      <th>Bid Point</th>
                      <th>Win Point</th>
                  </tr>
              </thead>
              <tbody>
            
              </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
  <!-- users view card details ends -->

</section>
<!-- users view ends -->

        </div>
      </div>
    </div>
    <!-- END: Content-->
    <div class="sidenav-overlay"></div>
    <div class="drag-target"></div>
     <!-- Earning Swiper Starts -->
  @include('admin.layout.footer')
  @include('admin.modal.view_transaction')
  <script>
  $(document).ready( function () {

    var user_id = "{{$user->id}}";
    var user_type = "User";

    var WithdrawalTable = $('#WithdrawalTable');
    var TransactionTable = $('#TransactionTable');
    var BiddingTable = $('#BiddingTable');

      WithdrawalTable.DataTable({

          responsive: true,
          serverSide: true,
          processing: true,
          ordering: false,
          ajax:{
                url:"{{url('withdrawals/data')}}",
                data:{'user_id': user_id,'user_type': user_type},
              },
          "aoColumns": [
              {
                  mData: 'request_number'
              },
              {
                  mData: 'bank_details'
              },
              {
                  mData: 'requested_at'
              },
              {
                  mData: 'amount'
              },
              {
                  mData: 'payout_id'
              },
              {
                  mData: 'status'
              },
          ],
          "columnDefs": [{
              targets: -1,
              className: 'text-right'
          }],
      });

    TransactionTable.DataTable({
          responsive: true,
          serverSide: true,
          processing: true,
          ordering: false,
          ajax:{
                url:"{{url('transactions/data')}}",
                data:{'user_id': user_id,'user_type': user_type}, 
              },
          "aoColumns": [
              {
                  mData: 'transaction_id'
              },
              {
                  mData: 'amount'
              },
              {
                  mData: 'transaction_at'
              },
              {
                  mData: 'payment_type'
              },
              {
                  mData: 'payment_status'
              },
          ],
          "columnDefs": [{
              targets: -1,
              className: 'text-right'
          }],
      });

    BiddingTable.DataTable({
          responsive: true,
          serverSide: true,
          processing: true,
          ordering: false,
          ajax:{
                url:"{{url('users/bidding/data')}}",
                data:{'user_id': user_id,'user_type': user_type}, 
              },
          "aoColumns": [
              {
                  mData: 'market_name'
              },
              {
                  mData: 'game_type'
              },
              {
                  mData: 'date'
              },
              {
                  mData: 'result_time'
              },
              {
                  mData: 'biddings'
              },
              {
                  mData: 'total_biddings_point'
              },
              {
                  mData: 'total_winnings_point'
              },
          ],
          "columnDefs": [{
              targets: -1,
              className: 'text-right'
          }],
      });
});
</script>

</body>
<!-- END: Body-->

</html>