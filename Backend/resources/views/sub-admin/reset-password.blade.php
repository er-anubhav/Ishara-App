<!DOCTYPE html>

<html class="loading" lang="en" data-textdirection="ltr">

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0">
    <meta name="author" content="LeadStep">
    <title>Reset Password - LeadStep</title>
    <link rel="shortcut icon" type="image/x-icon" href="{{url('app-assets/images/logo/fab_icon_min.png')}}">
    <link href="https://fonts.googleapis.com/css?family=Rubik:300,400,500,600%7CIBM+Plex+Sans:300,400,500,600,700" rel="stylesheet">

    <!-- BEGIN: Vendor CSS-->
    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/vendors/css/vendors.min.css') }}">
    <!-- END: Vendor CSS-->

    <!-- BEGIN: Theme CSS-->
    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/css/bootstrap.min.css') }}">
    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/css/bootstrap-extended.min.css') }}">
    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/css/colors.min.css') }}">
    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/css/components.min.css') }}">
    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/css/themes/dark-layout.min.css') }}">
    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/css/themes/semi-dark-layout.min.css') }}">
    <!-- END: Theme CSS-->

    <!-- BEGIN: Page CSS-->
    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/css/core/menu/menu-types/vertical-menu.min.css') }}">
    <link rel="stylesheet" type="text/css" href="{{ asset('app-assets/css/pages/authentication.css') }}">
    <!-- END: Page CSS-->

    <!-- BEGIN: Custom CSS-->
    <link rel="stylesheet" type="text/css" href="{{ asset('assets/css/style.css') }}">
    <!-- END: Custom CSS-->
    <style>
      select.form-control:not([multiple]){
        padding-right:2rem;
      }
      .leadstep-logo, .programmics-logo{
            text-align: center;
        }

        .leadstep-logo img{
            height: 80px;
        }

        .programmics-logo a img{
            height: 40px;
        }
        .leadstep-logo{
            margin-right: 20px;
        }
      .email{

        margin-top: 5px;
        margin-left: 5px;
        font-size: 17px;
      }
    html .bg-full-screen-image{
            background: url("{{ asset('app-assets/images/pages/auth-bg-full-dark.jpg') }}") center center no-repeat;
            background-size:cover;
            backdrop-filter: blur(5px);
    }
  </style>
  </head>
  <!-- END: Head-->

  <!-- BEGIN: Body-->
<body class="vertical-layout vertical-menu-modern 1-column  navbar-sticky footer-static bg-full-screen-image  blank-page" data-open="click" data-menu="vertical-menu-modern" data-col="1-column">
<!-- BEGIN: Content-->
<div class="app-content content">
  <div class="content-overlay"></div>
  <div class="content-wrapper">
    <div class="content-header row"></div>
    <div class="content-body">
        @if(Session::has('success'))
        <section class="row flexbox-container">
        <div class="col-xl-4 col-md-6 col-10  p-0">
        <div class="card bg-authentication mb-0">
        <div class="row m-0">
        <div class="alert alert-primary m-2" role="alert">
            <h4 class="alert-heading">You have reset your password successfully</h4>
            <p>We have sent an email for your password conformation.</p>
            <hr>
            <a href="{{url('/')}}" class="alert-link text-white float-right mr-1">Login</a>
        </div>
        </div></div></div></section>
        @else
<section class="row flexbox-container">
    <div class="col-12 leadstep-logo">
        <img src="{{url('app-assets/images/logo/light_logo_min.png')}}">
    </div>
    <div class="col-xl-7 col-10">
        <div class="card bg-authentication mb-0">
            <div class="row m-0">
                <!-- left section-login -->
                <div class="col-md-6 col-12 px-0">
                    <div class="card disable-rounded-right d-flex justify-content-center mb-0 p-2 h-100">
                        <div class="card-header pb-1">
                            <div class="card-title">
                                <h4 class="text-center mb-2">Reset your Password</h4>
                            </div>
                        </div>
                        <div class="card-body">
                            <form class="mb-2" id="login-form" method="POST" action="">
                                @csrf

                                <input type="hidden" name="token" value="{{ $request->route('token') }}">
                                <input type="hidden" name="email" value="{{ $request->route('email') }}">
                                <div class="form-group">
                                    <label class="text-bold-600" for="password">New Password</label>
                                    <input type="password" name="password" class="form-control @error('password') is-invalid @enderror" value="{{ old('password') }}" id="password"
                                        placeholder="Enter a new password" required autofocus>@error('password')
                                            <span class="invalid-feedback" role="alert">
                                                <strong>{{ $message }}</strong>
                                            </span>
                                            @enderror</div>
                                <div class="form-group mb-2 mt-1">
                                    <label class="text-bold-600" for="password_confirmation">Confirm New
                                        Password</label>
                                    <input type="password" name="password_confirmation" class="form-control @error('password_confirmation') is-invalid @enderror" id="password_confirmation"
                                        placeholder="Confirm your new password">@error('password_confirmation')
                                            <span class="invalid-feedback" role="alert">
                                                <strong>{{ $message }}</strong>
                                            </span>
                                            @enderror</div>
                                <button type="submit" class="btn btn-secondary glow position-relative w-100 mt-1 submit-btn">Reset my
                                    password<i id="icon-arrow" class="bx bx-right-arrow-alt"></i></button>
                            </form>
                        </div>
                    </div>
                </div>
                <!-- right section image -->
                <div class="col-md-6 d-md-block d-none text-center align-self-center p-3">
                    <img class="img-fluid" src="{{url('app-assets/images/pages/reset-password.png')}}"
                        alt="branding logo">
                </div>
            </div>
        </div>
    </div>
    <div class="col-12 programmics-logo mt-6">
        <a href="https://www.programmics.co.in/" target="_BLANK" class="mb-0"><img src="{{url('app-assets/images/logo/programmics_logo_min.png')}}" class="mb-0"></a>
        <p class="mb-0 text-white">@ 2020 Programmics Technology. All Rights Reserved</p>
    </div>
</section>
@endif
    </div>
  </div>
</div>
<!-- END: Content-->

    <!-- BEGIN: Vendor JS-->
    <script src="{{ asset('app-assets/vendors/js/vendors.min.js') }}"></script>
    <script src="{{ asset('app-assets/fonts/LivIconsEvo/js/LivIconsEvo.tools.min.js') }}"></script>
    <script src="{{ asset('app-assets/fonts/LivIconsEvo/js/LivIconsEvo.defaults.min.js') }}"></script>
    <script src="{{ asset('app-assets/fonts/LivIconsEvo/js/LivIconsEvo.min.js') }}"></script>

    <script src="{{ asset('app-assets/js/scripts/configs/vertical-menu-light.min.js') }}"></script>
    <script src="{{ asset('app-assets/js/core/app-menu.min.js') }}"></script>
    <script src="{{ asset('app-assets/js/core/app.min.js') }}"></script>
    <script src="{{ asset('app-assets/js/scripts/components.min.js') }}"></script>
    <script src="{{ asset('app-assets/js/scripts/footer.min.js') }}"></script>

    <script>
        
        $(document).ready(function () {
            $("#login-form").submit(function () {
                $(".submit-btn").attr("disabled", true);
                return true;
            });
        });

    </script>
  </body>
</html>
