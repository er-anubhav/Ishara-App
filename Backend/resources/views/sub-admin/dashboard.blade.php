<!DOCTYPE html>

<html class="loading" lang="en" data-textdirection="ltr">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0">
    <title>Dashboard - 888Playwin</title>
@include('admin.layout.header')
<style>
  #widgets-Statistics .row .col-xl-2 .card:hover{
    box-shadow: -8px 12px 18px 0 rgba(25,42,70,.13);
  }
  #widgets-Statistics .row .col-xl-2 .card{
    cursor: pointer;
    box-shadow: 0px 0px 0px 0 rgba(25,42,70,.13);
    /*clip-path: polygon(0% 0%, 75% 0%, 100% 50%, 75% 100%, 0% 100%);*/
    clip-path: polygon(75% 0%, 100% 50%, 75% 100%, 0% 100%, 25% 50%, 0% 0%);
  }
  .active-label{
    box-shadow: -8px 12px 18px 0 rgb(25 42 70 / 38%) !important;
    background-color: #32557f;
    color: white !important;
  }
  .active-label p{
    color: #ffffffe0 !important;
  }
  .active-label h2{
    color: #ffffff !important;
  }

  .deal-add-label{
    cursor: pointer;
    background-color: #80808063;  
    clip-path: polygon(75% 0%, 93% 48%, 78% 100%, 0% 100%, 10% 49%, 0% 0%); 
    height:35px;
  }
  .deal-add-label-active{
    cursor: pointer;
    background-color: #32557f;
    clip-path: polygon(75% 0%, 93% 48%, 78% 100%, 0% 100%, 10% 49%, 0% 0%); 
    height:35px;
  }
  .deal-add-label p, .deal-add-label-active p{
    position: relative;
    top: 6px;
    color: white;
    text-align: center;
    font-size: 13px;
  }
</style>
    <!-- BEGIN: Content-->
    <div class="app-content content">
      <div class="content-overlay"></div>
      <div class="content-wrapper">
        <div class="content-header row">
        </div>
        <div class="content-body">
          <!-- Dashboard Analytics Starts -->
          <section id="widgets-Statistics" style="margin-top: 15px;">
            <div class="row">
                <div class="col-md-7 col-sm-12">
                  <div class="card">
                    <div class="row pt-1 pl-1 pr-1">
                      <div class="col-xl-4 col-lg-4 col-md-4 col-12 float-left">
                        <h4 class="card-title float-left">User Analytics</h4>
                      </div>
                      <div class="col-xl-8 col-lg-8 col-md-8 col-12 float-right">
                        <div class="form-group position-relative has-icon-left float-right">
                          <input type="text" class="form-control daterange-filter" id="user-analytics-date-range" placeholder="Select Date" value="{{date('d/m/Y',strtotime('-7 days'))}} - {{ date('d/m/Y')}}" autocomplete="off" style="width: 250px;"> 
                          <div class="form-control-position">
                            <i class='bx bx-calendar-check'></i>
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="card-body pb-1 pt-0">
                      <div id="user-analytics-chart"></div>
                    </div>
                  </div>
                </div>

                <div class="col-md-5 col-sm-12">
                  <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                      <h4 class="card-title">Website Analytics</h4>
                    </div>
                    <div class="card-body pb-0">
                      <div class="d-flex justify-content-around align-items-center flex-wrap">
                        <div class="user-analytics mr-2">
                          <i class="bx bx-user mr-25 align-middle"></i>
                          <span class="align-middle text-muted">Users</span>
                          <div class="d-flex">
                            <div id="radial-success-chart"></div>
                            <h3 class="mt-1 ml-50">{{$data['users']}}</h3>
                          </div>
                        </div>
                        <div class="sessions-analytics mr-2">
                          <i class="bx bx-game align-middle mr-25"></i>
                          <span class="align-middle text-muted">Games</span>
                          <div class="d-flex">
                            <div id="profit-primary-chart"></div>
                            <h3 class="mt-1 ml-50">{{$data['games']}}</h3>
                          </div>
                        </div>
                      </div>
                    </div>

                    <div class="card-body pb-0 pt-0" style="max-height: 290px;overflow: auto;">
                      <ul class="list-group list-group-flush">
                        <li
                          class="list-group-item list-group-item-action border-0 d-flex align-items-center justify-content-between">
                          <div class="list-left d-flex">
                            <div class="list-icon mr-1">
                              <div class="avatar bg-rgba-primary m-0">
                                <div class="avatar-content">
                                  <i class="bx bx-user text-primary font-size-base"></i>
                                </div>
                              </div>
                            </div>
                            <div class="list-content">
                              <span class="list-title">Total Participants</span>
                              <small class="text-muted d-block">{{$data['today_participants']}} Participants Today</small>
                            </div>
                          </div>
                          <span>{{$data['total_participants']}}</span>
                        </li>
                        <li
                          class="list-group-item list-group-item-action border-0 d-flex align-items-center justify-content-between">
                          <div class="list-left d-flex">
                            <div class="list-icon mr-1">
                              <div class="avatar bg-rgba-info m-0">
                                <div class="avatar-content">
                                  <i class="bx bx-stats text-info font-size-base"></i>
                                </div>
                              </div>
                            </div>
                            <div class="list-content">
                              <span class="list-title">Total Profit/Loss</span>
                              @if($data['today_revenue'] == 0)
                              <small class="text-muted d-block">0 Profit Today</small>
                              @else
                              <small class="text-muted d-block">{{$data['today_revenue']}} @if($data['is_today_profit']) Profit @else Loss @endif Today</small>
                              @endif
                            </div>
                          </div>
                          @if($data['is_total_profit'])
                          <span style="color:green;">+{{$data['total_revenue']}}</span>
                          @else
                          <span style="color:red;">-{{$data['total_revenue']}}</span>
                          @endif
                        </li>
                        <li
                          class="list-group-item list-group-item-action border-0 d-flex align-items-center justify-content-between">
                          <div class="list-left d-flex">
                            <div class="list-icon mr-1">
                              <div class="avatar bg-rgba-danger m-0">
                                <div class="avatar-content">
                                  <i class="bx bx-credit-card text-danger font-size-base"></i>
                                </div>
                              </div>
                            </div>
                            <div class="list-content">
                              <span class="list-title">Total Withdarwal Request</span>
                              <small class="text-muted d-block">{{$data['today_withdrawals']}} New Request's</small>
                            </div>
                          </div>
                          <span>{{$data['total_withdrawals']}}</span>
                        </li>
                        <li
                          class="list-group-item list-group-item-action border-0 d-flex align-items-center justify-content-between">
                          <div class="list-left d-flex">
                            <div class="list-icon mr-1">
                              <div class="avatar bg-rgba-success m-0">
                                <div class="avatar-content">
                                  <i class="bx bx-dollar text-success font-size-base"></i>
                                </div>
                              </div>
                            </div>
                            <div class="list-content">
                              <span class="list-title">Total Add Money Request</span>
                              <small class="text-muted d-block">{{$data['today_wallet_credit_requests']}} New Request's</small>
                            </div>
                          </div>
                          <span>{{$data['total_wallet_credit_requests']}}</span>
                        </li>
                        
                        <li
                          class="list-group-item list-group-item-action border-0 d-flex align-items-center justify-content-between">
                          <div class="list-left d-flex">
                            <div class="list-icon mr-1">
                              <div class="avatar bg-rgba-danger m-0">
                                <div class="avatar-content">
                                  <i class="bx bx-edit-alt text-danger font-size-base"></i>
                                </div>
                              </div>
                            </div>
                            <div class="list-content">
                              <span class="list-title">Total Transactions</span>
                              <small class="text-muted d-block">{{$data['today_transactions']}} New Transactions</small>
                            </div>
                          </div>
                          <span>{{$data['total_transactions']}}</span>
                        </li>
                      </ul>
                    </div>

                  </div>
                </div>
                
                <div class="col-lg-6 col-md-12">
                  <div class="card">
                    <div class="row pt-1 pl-1 pr-1">
                      <div class="col-xl-4 col-lg-4 col-md-4 col-12 float-left">
                        <h4 class="card-title float-left">Game Profit/Loss</h4>
                      </div>
                      <div class="col-xl-8 col-lg-8 col-md-8 col-12 float-right">
                        <div class="form-group position-relative has-icon-left float-right">
                          <input type="text" class="form-control daterange-filter" id="game-profit-loss-date-range" placeholder="Select Date" value="{{date('d/m/Y',strtotime('-30 days'))}} - {{ date('d/m/Y')}}" autocomplete="off" style="width: 250px;"> 
                          <div class="form-control-position">
                            <i class='bx bx-calendar-check'></i>
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="card-body pt-0">
                      <div id="game-profit-loss-chart"></div>
                    </div>
                  </div>
                </div>

                <div class="col-lg-6 col-md-12">
                  <div class="card">
                    <div class="row pt-1 pl-1 pr-1">
                      <div class="col-xl-4 col-lg-4 col-md-4 col-12 float-left">
                        <h4 class="card-title float-left">Game Participation</h4>
                      </div>
                      <div class="col-xl-8 col-lg-8 col-md-8 col-12 float-right">
                        <div class="form-group position-relative has-icon-left float-right">
                          <input type="text" class="form-control daterange-filter" id="game-participation-date-range" placeholder="Select Date" value="{{date('d/m/Y',strtotime('-30 days'))}} - {{ date('d/m/Y')}}" autocomplete="off" style="width: 250px;"> 
                          <div class="form-control-position">
                            <i class='bx bx-calendar-check'></i>
                          </div>
                        </div>
                      </div>
                    </div>
                    <div class="card-body pt-0">
                      <div id="game-participation-chart"></div>
                    </div>
                  </div>
                </div>

            </div>
          </section>
    </div></div></div>
    <div class="sidenav-overlay"></div>
    <div class="drag-target"></div>
     <!-- Earning Swiper Starts -->
    
            
@include('admin.layout.footer')
<script src="{{ asset('app-assets/js/scripts/pages/dashboard-analytics.min.js') }}"></script>
</body>
</html>
<script>
  
  $(".daterange-filter").daterangepicker({
    locale: {
      format: 'DD-MM-YYYY'
    },
    minYear: 1901,
    maxYear: parseInt(moment().format("YYYY"), 10),
    // singleDatePicker: !0,
    showDropdowns: !0
    // singleDatePicker: false,
  });

  $("#user-analytics-date-range").on("change", function(e){
    e.preventDefault();
    render_user_chart($(this).val());
  });
  $("#game-profit-loss-date-range").on("change", function(e){
    e.preventDefault();
    render_game_wise_profit_loss_chart($(this).val());
  });
  $("#game-participation-date-range").on("change", function(e){
    e.preventDefault();
    render_game_participation_chart($(this).val());
  });

  render_user_chart($("#user-analytics-date-range").val());
  render_game_wise_profit_loss_chart($("#game-profit-loss-date-range").val());
  render_game_participation_chart($("#game-participation-date-range").val());

  function render_user_chart(daterange = "")
  {
      $.getJSON("{{ url('/user-chart-data') }}", {daterange}, function(response) {

          var e = "#5A8DEE",
          t = [e, "#FDAC41", "#FF5B5C", "#39DA8A", "#00CFDD"],
          i = {
          chart: {
              height: 350,
              type: "area",
              stacked: !1
          },
          colors: t,
          stroke: {
              width: [0, 2, 5],
              curve: "smooth"
          },
          plotOptions: {
              bar: {
                  columnWidth: "10%"
              }
          },
          series: [],
          fill: {
              opacity: [.85, .25, 1],
              gradient: {
                  inverseColors: !1,
                  shade: "light",
                  type: "vertical",
                  opacityFrom: .85,
                  opacityTo: .75,
                  stops: [0, 100, 100, 100]
              }
          },
          labels: response.dates,
          markers: {
              size: 0
          },
          legend: {
              offsetY: 8
          },
          xaxis: {
              type: "date",
          },
          yaxis: {
              min: 0,
              tickAmount: 5,
              title: {
                  text: "Users"
              }
          },
          tooltip: {
              shared: !0,
              intersect: !1,
              y: {
                  formatter: function(e) {
                      return e
                  }
              }
          }
        };
        
        var dchart = new ApexCharts(document.querySelector("#user-analytics-chart"), i);
        dchart.render();

        dchart.updateSeries([{
          name: 'Users',
          type: "column",
          data: response.users
        }])

      });
    }

  function render_game_wise_profit_loss_chart(daterange = "")
  {
    $.getJSON("{{ url('/game-profit-loss-chart-data') }}", {daterange}, function(response) {

        var t = ["#5A8DEE", "#FF5959", "#FF5B5C", "#39DA8A", "#00CFDD"];
        var o = {
          chart: { height: 350, type: "bar" },
          colors: t,

          plotOptions: { bar: { horizontal: !0 } },
          dataLabels: { enabled: !1 },
          // series: [{ data: response.profit_loss }],
          series: [
              {
                name: 'Profit',
                type: 'bar',
                data: response.profit,
              },
              {
                name: "Loss",
                type: 'bar',
                data: response.loss,
              },
            ],
          xaxis: { categories: response.market_names, tickAmount: 5 },
      };
      new ApexCharts(document.querySelector("#game-profit-loss-chart"), o).render();
    });
  }

  function render_game_participation_chart(daterange = "")
  {
    $.getJSON("{{ url('/game-participation-chart-data') }}", {daterange}, function(response) {

        var e = "#5A8DEE",
          t = [e, "#FDAC41", "#FF5B5C", "#39DA8A", "#00CFDD"];
        var o = {
          chart: { height: 350, type: "bar" },
          colors: t,
          plotOptions: { bar: { horizontal: !0 } },
          dataLabels: { enabled: !1 },
          series: [{name: 'Participation', data: response.participants }],
          xaxis: { categories: response.market_names, tickAmount: 5, seriesName: 'Profit', labels: {
            formatter: function(val, index) {
              return Math.floor(val);
            }
          } 
          },
          tooltip: {
                shared: !0,
                intersect: !1,
                y: {
                    formatter: function(e) {
                        return Math.floor(e);
                    }
                }
            }
      };
      new ApexCharts(document.querySelector("#game-participation-chart"), o).render();
    });
  }

</script>