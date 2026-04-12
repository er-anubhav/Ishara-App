
 
    <link rel="shortcut icon" type="image/x-icon" href="https://www.pixinvent.com/demo/frest-clean-bootstrap-admin-dashboard-template/app-assets/images/ico/favicon.ico">
    <link href="https://fonts.googleapis.com/css?family=Rubik:300,400,500,600%7CIBM+Plex+Sans:300,400,500,600,700" rel="stylesheet">

    <!-- BEGIN: Vendor CSS-->
    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/vendors/css/vendors.min.css ') }}">
    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/vendors/css/charts/apexcharts.css ') }}">
    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/vendors/css/extensions/swiper.min.css ') }}">
    <!-- END: Vendor CSS-->


    <!-- BEGIN: Theme CSS-->
    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/css/bootstrap.min.css ') }}">
    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/css/bootstrap-extended.min.css ') }}">
    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/css/colors.min.css ') }}">
    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/css/components.min.css ') }}">
    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/css/themes/dark-layout.min.css ') }}">
    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/css/themes/semi-dark-layout.min.css ') }}">
    <!-- END: Theme CSS-->

    <!-- BEGIN: Page CSS-->
    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/css/core/menu/menu-types/vertical-menu.min.css ') }}">
    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/css/pages/dashboard-ecommerce.min.css ') }}">
    <!-- END: Page CSS-->

    <!-- BEGIN: Custom CSS-->
    <!-- <link rel="stylesheet" type="text/css" href="{{ asset('assets/css/style.css ') }}"> -->
    <!-- END: Custom CSS-->
 
    <!-- <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/vendors/css/tables/datatable/dataTables.bootstrap4.min.css ') }}"> -->
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.23/css/jquery.dataTables.min.css">

    <link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.3.1/semantic.min.css">


    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/vendors/css/tables/datatable/responsive.bootstrap4.min.css ') }}">
    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/vendors/css/tables/datatable/buttons.bootstrap4.min.css ') }}">
    
    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/css/plugins/forms/wizard.min.css ') }}">

    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/vendors/css/animate/animate.css') }}">

    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/vendors/css/extensions/sweetalert2.min.css') }}">
    
    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/vendors/css/forms/select/select2.min.css') }}">

    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/vendors/css/pickers/pickadate/pickadate.css') }}">
    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/vendors/css/pickers/daterange/daterangepicker.css') }}">

    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/css/pages/app-invoice.min.css') }}">
  </head>
  <!-- END: Head-->
<style>
    .header-navbar.fixed-top {
    left: 260px;
    position: fixed;
    background-color: #f3ffff;
   
    box-shadow: -8px 12px 18px 0 rgba(25,42,70,.13);
}
.navbar-header{
  margin-bottom: 10px;
}
.select2-container--default .select2-selection--single{
 border:1px solid #aaa6;
}
.table thead th{
  color: #021832 !important
  /*font-size: 0.9rem !important;
  letter-spacing: 0.5px !important;*/
}
@media screen and (max-width: 1280px) and (min-width: 768px) {
.dashboard-earning-swiper, .dashboard-greetings, .dashboard-latest-update, .dashboard-visit {
    max-width: 100%!important;
    -webkit-box-flex: 1;
    -webkit-flex: auto;
    -ms-flex: auto;
    flex: auto;
}
.header-navbar.fixed-top {
     left: 0px; 
    position: fixed;
    background-color: #f3ffff;
    box-shadow: -8px 12px 18px 0 rgb(25 42 70 / 13%);
}
}

    </style>
  <!-- BEGIN: Body-->
  <body class="vertical-layout vertical-menu-modern 2-columns  navbar-sticky footer-static  " data-open="click" data-menu="vertical-menu-modern" data-col="2-columns">

    <!-- BEGIN: Header-->
    <div class="header-navbar-shadow"></div>
    <nav class="header-navbar main-header-navbar navbar-expand-lg navbar navbar-with-menu fixed-top ">
      <div class="navbar-wrapper">
        <div class="navbar-container content">
          <div class="navbar-collapse" id="navbar-mobile">
            <div class="mr-auto float-left bookmark-wrapper d-flex align-items-center">
              <ul class="nav navbar-nav">
                <li class="nav-item mobile-menu d-xl-none mr-auto"><a class="nav-link nav-menu-main menu-toggle hidden-xs" href="javascript:void(0);"><i class="ficon bx bx-menu"></i></a></li>
              </ul>
              <ul class="nav navbar-nav bookmark-icons">
                <li class="nav-item d-none d-lg-block"><a class="nav-link" href="{{url('/')}}/{{request()->path()}}" > 
                    <h3><?php if (request()->path() == 'home') {
                                    echo 'Dashboard';
                                }elseif (request()->path() == 'users') {
                                  echo 'Users';
                                }elseif (request()->path() == 'cms/create') {
                                  echo 'Create Page';
                                }elseif (request()->path() == 'cms/manage') {
                                  echo 'Manage Page';
                                }elseif (request()->path() == 'cms/themes') {
                                  echo 'Theme SetUp';
                                }elseif (request()->path() == 'cms/home') {
                                  echo 'Home SetUp';
                                }elseif (request()->path() == 'payment-settings') {
                                  echo 'Payment Settings';
                                }elseif (request()->path() == 'transactions') {
                                  echo 'Transactions';
                                }elseif (request()->path() == 'withdrawals') {
                                  echo 'Withdrawals';
                                }elseif (request()->path() == 'finance-manager') {
                                  echo 'Finance Manager'; 
                                }elseif (request()->path() == 'add-money') {
                                  echo 'Add Money';
                                }elseif (request()->path() == 'payment-accept') {
                                  echo 'Payment Accept Details';
                                }elseif (request()->path() == 'sms-logs') {
                                  echo 'SMS Logs';
                                }else{
                                  $path = explode('/', request()->path());
                                  if (sizeof($path) == 3) {
                                     if (strtolower($path[0]) == 'users' && is_numeric($path[1])) {
                                       echo ucwords(str_replace('-',' ', $path[2]));
                                     }elseif(strtolower($path[0]) == 'market' && strtolower($path[1]) == 'edit'){
                                        echo 'Update Market';
                                     }elseif(strtolower($path[0]) == 'market' && strtolower($path[1]) == 'market-timing-view'){
                                        echo 'Market Timings';
                                     }else{
                                      echo ucwords(str_replace('-',' ', str_replace('/', ' ', request()->path())));
                                     }
                                  }else{
                                    echo ucwords(str_replace('-',' ', str_replace('/', ' ', request()->path())));
                                  }
                                } ?> 
                    </h3></a>  
                </li>
              </ul>
            </div>
            <ul class="nav navbar-nav float-right">
              <li class="nav-item d-none d-lg-block"><a class="nav-link nav-link-expand"><i class="ficon bx bx-fullscreen"></i></a></li>
              <li class="dropdown dropdown-user nav-item"><a class="dropdown-toggle nav-link dropdown-user-link" href="javascript:void(0);" data-toggle="dropdown">
                  <div class="user-nav d-sm-flex d-none"><span class="user-name">888Playwin</span><span class="user-status text-muted">{{auth()->user()->name}}</span></div><span><img class="round" src="{{ asset('app-assets/images/portrait/small/avatar-s-11.png ') }}" alt="avatar" height="40" width="40"></span></a>
                <div class="dropdown-menu dropdown-menu-right p-0">
                   <a class="dropdown-item" href="#" data-toggle="modal" data-target="#password_change_modal"><i class='bx bxs-lock-alt mr-50'></i> Change Password</a>
                  <a class="dropdown-item" href="{{ route('logout') }}"
                                       onclick="event.preventDefault();
                                                     document.getElementById('logout-form').submit();"><i class="bx bx-power-off mr-50"></i> Logout</a>
                                                     <form id="logout-form" action="{{ route('logout') }}" method="POST" class="d-none">
                                        @csrf
                                    </form>
                </div>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </nav>
    <!-- END: Header-->


    <!-- BEGIN: Main Menu-->
    <div class="main-menu menu-fixed menu-accordion menu-shadow expanded menu-dark" data-scroll-to-active="true">
      <div class="navbar-header">
        <ul class="nav navbar-nav flex-row">
          <li class="nav-item mr-auto"><a class="navbar-brand" href="{{url('home')}}">
              <div class="brand-logo">
                <svg class="logo" width="26px" height="26px" viewbox="0 0 26 26" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
                  <title>icon</title>
                  <defs>
                    <lineargradient id="linearGradient-1" x1="50%" y1="0%" x2="50%" y2="100%">
                      <stop stop-color="#5A8DEE" offset="0%"></stop>
                      <stop stop-color="#699AF9" offset="100%"></stop>
                    </lineargradient>
                    <lineargradient id="linearGradient-2" x1="0%" y1="0%" x2="100%" y2="100%">
                      <stop stop-color="#FDAC41" offset="0%"></stop>
                      <stop stop-color="#E38100" offset="100%"></stop>
                    </lineargradient>
                  </defs>
                  <g id="Sprite" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
                    <g id="sprite" transform="translate(-69.000000, -61.000000)">
                      <g id="Group" transform="translate(17.000000, 15.000000)">
                        <g id="icon" transform="translate(52.000000, 46.000000)">
                          <path id="Combined-Shape" d="M13.5909091,1.77272727 C20.4442608,1.77272727 26,7.19618701 26,13.8863636 C26,20.5765403 20.4442608,26 13.5909091,26 C6.73755742,26 1.18181818,20.5765403 1.18181818,13.8863636 C1.18181818,13.540626 1.19665566,13.1982714 1.22574292,12.8598734 L6.30410592,12.859962 C6.25499466,13.1951893 6.22958398,13.5378796 6.22958398,13.8863636 C6.22958398,17.8551125 9.52536149,21.0724191 13.5909091,21.0724191 C17.6564567,21.0724191 20.9522342,17.8551125 20.9522342,13.8863636 C20.9522342,9.91761479 17.6564567,6.70030817 13.5909091,6.70030817 C13.2336969,6.70030817 12.8824272,6.72514561 12.5388136,6.77314791 L12.5392575,1.81561642 C12.8859498,1.78721495 13.2366963,1.77272727 13.5909091,1.77272727 Z"></path>
                          <path id="Combined-Shape" d="M13.8863636,4.72727273 C18.9447899,4.72727273 23.0454545,8.82793741 23.0454545,13.8863636 C23.0454545,18.9447899 18.9447899,23.0454545 13.8863636,23.0454545 C8.82793741,23.0454545 4.72727273,18.9447899 4.72727273,13.8863636 C4.72727273,13.5378966 4.74673291,13.1939746 4.7846258,12.8556254 L8.55057141,12.8560055 C8.48653249,13.1896162 8.45300462,13.5340745 8.45300462,13.8863636 C8.45300462,16.887125 10.8856023,19.3197227 13.8863636,19.3197227 C16.887125,19.3197227 19.3197227,16.887125 19.3197227,13.8863636 C19.3197227,10.8856023 16.887125,8.45300462 13.8863636,8.45300462 C13.529522,8.45300462 13.180715,8.48740462 12.8430777,8.55306931 L12.8426531,4.78608796 C13.1851829,4.7472336 13.5334422,4.72727273 13.8863636,4.72727273 Z" fill="#4880EA"></path>
                          <path id="Combined-Shape" d="M13.5909091,1.77272727 C20.4442608,1.77272727 26,7.19618701 26,13.8863636 C26,20.5765403 20.4442608,26 13.5909091,26 C6.73755742,26 1.18181818,20.5765403 1.18181818,13.8863636 C1.18181818,13.540626 1.19665566,13.1982714 1.22574292,12.8598734 L6.30410592,12.859962 C6.25499466,13.1951893 6.22958398,13.5378796 6.22958398,13.8863636 C6.22958398,17.8551125 9.52536149,21.0724191 13.5909091,21.0724191 C17.6564567,21.0724191 20.9522342,17.8551125 20.9522342,13.8863636 C20.9522342,9.91761479 17.6564567,6.70030817 13.5909091,6.70030817 C13.2336969,6.70030817 12.8824272,6.72514561 12.5388136,6.77314791 L12.5392575,1.81561642 C12.8859498,1.78721495 13.2366963,1.77272727 13.5909091,1.77272727 Z" fill="url(#linearGradient-1)"></path>
                          <rect id="Rectangle" x="0" y="0" width="7.68181818" height="7.68181818"></rect>
                          <rect id="Rectangle" fill="url(#linearGradient-2)" x="0" y="0" width="7.68181818" height="7.68181818"></rect>
                        </g>
                      </g>
                    </g>
                  </g>
                </svg>
              </div>
              <h2 class="brand-text mb-0" style="margin-top: 0px;">888Playwin</h2></a></li>
          <li class="nav-item nav-toggle"><a class="nav-link modern-nav-toggle pr-0" data-toggle="collapse"><i class="bx bx-x d-block d-xl-none font-medium-4 primary"></i><i class="toggle-icon bx bx-disc font-medium-4 d-none d-xl-block primary" data-ticon="bx-disc"></i></a></li>
        </ul>
      </div>
      <div class="shadow-bottom"></div>
      <div class="main-menu-content">
        <ul class="navigation navigation-main" id="main-menu-navigation" data-menu="menu-navigation" data-icon-style="lines">
          </li>
          <li class="nav-item <?php if (request()->path() == 'home') {
                                    echo 'active';
                                } ?>"><a href="{{url('home')}}"><i class="ficon bx 
bxs-dashboard" data-icon="envelope-pull"></i><span class="menu-title text-truncate" data-i18n="Email">Dashboard</span></a>
          </li>

          @if(auth()->user()->role == 'Admin')
          <li class="nav-item <?php if (request()->path() == 'users') {
                                    echo 'active';
                                } ?>"><a href="{{url('users')}}"><i class="ficon bx bx-user" data-icon="check-alt"></i><span class="menu-title text-truncate" data-i18n="Todo">Users</span></a>
          </li>

          
          <li class="nav-item <?php if (request()->path() == 'cms/theme' || request()->path() == 'cms/home' || request()->path() == 'cms/create' || request()->path() == 'cms/manage') { echo 'open';} ?>"><a href="#"><i class="ficon bx bx-disc" data-icon="notebook"></i><span class="menu-title text-truncate" data-i18n="Invoice">CMS</span></a>
            <ul class="menu-content">
              <li class="<?php if (request()->path() == 'cms/create') {echo 'active';} ?>"><a class="d-flex align-items-center" href="{{url('cms/create')}}"><i class="bx bx-right-arrow-alt"></i><span class="menu-item text-truncate" data-i18n="Invoice List">Create</span></a>
              </li>
              <li class="<?php if (request()->path() == 'cms/manage') {echo 'active';} ?>"><a class="d-flex align-items-center" href="{{url('cms/manage')}}"><i class="bx bx-right-arrow-alt"></i><span class="menu-item text-truncate" data-i18n="Invoice List">Manage</span></a>
              </li>
              <li class="<?php if (request()->path() == 'cms/themes') {echo 'active';} ?>"><a class="d-flex align-items-center" href="{{url('cms/themes')}}"><i class="bx bx-right-arrow-alt"></i><span class="menu-item text-truncate" data-i18n="Invoice List">Theme</span></a>
              </li>
              <li class="<?php if (request()->path() == 'cms/home') {echo 'active';} ?>"><a class="d-flex align-items-center" href="{{url('cms/home')}}"><i class="bx bx-right-arrow-alt"></i><span class="menu-item text-truncate" data-i18n="Invoice List">Home</span></a>
              </li>
            </ul>
          </li>

          @endif

          @if(auth()->user()->role == 'Admin' || auth()->user()->role == 'Finance Manager')
          <li class="nav-item <?php if (request()->path() == 'payment-settings' || request()->path() == 'transactions' || request()->path() == 'withdrawals') { echo 'open';} ?>"><a href="#"><i class="ficon bx bx-disc" data-icon="notebook"></i><span class="menu-title text-truncate" data-i18n="Invoice">Pay & Transactions</span></a>
            <ul class="menu-content">
              <li class="<?php if (request()->path() == 'transactions') {echo 'active';} ?>"><a class="d-flex align-items-center" href="{{url('transactions')}}"><i class="bx bx-right-arrow-alt"></i><span class="menu-item text-truncate" data-i18n="Invoice List">Transactions</span></a>
              </li>
              <li class="<?php if (request()->path() == 'withdrawals') {echo 'active';} ?>"><a class="d-flex align-items-center" href="{{url('withdrawals')}}"><i class="bx bx-right-arrow-alt"></i><span class="menu-item text-truncate" data-i18n="Invoice List">Withdrawal</span></a>
              </li>
              <li class="<?php if (request()->path() == 'add-money') {echo 'active';} ?>"><a class="d-flex align-items-center" href="{{url('add-money')}}"><i class="bx bx-right-arrow-alt"></i><span class="menu-item text-truncate" data-i18n="Invoice List">Add Money</span></a>
              </li>
              <li class="<?php if (request()->path() == 'sms-logs') {echo 'active';} ?>"><a class="d-flex align-items-center" href="{{url('sms-logs')}}"><i class="bx bx-right-arrow-alt"></i><span class="menu-item text-truncate" data-i18n="Invoice List">SMS Logs</span></a>
              </li>
              <li class="<?php if (request()->path() == 'payment-settings') {echo 'active';} ?>"><a class="d-flex align-items-center" href="{{url('payment-settings')}}"><i class="bx bx-right-arrow-alt"></i><span class="menu-item text-truncate" data-i18n="Invoice List">Pay Limit</span></a>
              </li>
              <li class="<?php if (request()->path() == 'payment-accept') {echo 'active';} ?>"><a class="d-flex align-items-center" href="{{url('payment-accept')}}"><i class="bx bx-right-arrow-alt"></i><span class="menu-item text-truncate" data-i18n="Invoice List">Pay Accept</span></a>
              </li>
            </ul>
          </li>
          @endif

          @if(auth()->user()->role == 'Admin' || auth()->user()->role == 'Result Announcer')
          <li class="nav-item <?php if (request()->path() == 'market/add' || request()->path() == 'market/list' || request()->path() == 'market/game-type') { echo 'open';} ?>"><a href="#"><i class="ficon bx bx-disc" data-icon="notebook"></i><span class="menu-title text-truncate" data-i18n="Invoice">Markets</span></a>
            <ul class="menu-content">

              @if(auth()->user()->role == 'Admin')
              <li class="<?php if (request()->path() == 'market/add') {echo 'active';} ?>"><a class="d-flex align-items-center" href="{{url('market/add')}}"><i class="bx bx-right-arrow-alt"></i><span class="menu-item text-truncate" data-i18n="Invoice List">Add</span></a>
              </li>
              @endif
              <li class="<?php if (request()->path() == 'market/list') {echo 'active';} ?>"><a class="d-flex align-items-center" href="{{url('market/list')}}"><i class="bx bx-right-arrow-alt"></i><span class="menu-item text-truncate" data-i18n="Invoice List">List</span></a>
              </li>

              @if(auth()->user()->role == 'Admin')
              <li class="<?php if (request()->path() == 'market/game-type') {echo 'active';} ?>"><a class="d-flex align-items-center" href="{{url('market/game-type')}}"><i class="bx bx-right-arrow-alt"></i><span class="menu-item text-truncate" data-i18n="Invoice List">Game Type</span></a>
              </li>
              @endif
            </ul>
          </li>
          @endif

          <li class="nav-item <?php if (request()->path() == 'market/report') {
                  echo 'active';
              } ?>"><a href="{{url('market/report')}}"><i class="ficon bx bxs-report" data-icon="check-alt"></i><span class="menu-title text-truncate" data-i18n="Todo">Report</span></a>
          </li>

          @if(auth()->user()->role == 'Admin')

          <li class="nav-item <?php if (request()->path() == 'finance-manager' || request()->path() == 'result-announcer') { echo 'open';} ?>"><a href="#"><i class="ficon bx bx-disc" data-icon="notebook"></i><span class="menu-title text-truncate" data-i18n="Invoice">Managements</span></a>
            <ul class="menu-content">
              <li class="<?php if (request()->path() == 'finance-manager') {echo 'active';} ?>"><a class="d-flex align-items-center" href="{{url('finance-manager')}}"><i class="bx bx-right-arrow-alt"></i><span class="menu-item text-truncate" data-i18n="Invoice List">Finance Manager</span></a>
              </li>
              <li class="<?php if (request()->path() == 'result-announcer') {echo 'active';} ?>"><a class="d-flex align-items-center" href="{{url('result-announcer')}}"><i class="bx bx-right-arrow-alt"></i><span class="menu-item text-truncate" data-i18n="Invoice List">Result Announcer</span></a>
              </li>
            </ul>
          </li>
          @endif
        </ul>
      </div>
    </div>
    <!-- END: Main Menu-->