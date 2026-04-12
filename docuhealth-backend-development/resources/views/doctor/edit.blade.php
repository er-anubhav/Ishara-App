<?php
$auth = auth()->user()->role;
$auth_path = auth()->user()->role == 'admin' ? 'admin' : '' ;
?>
<!DOCTYPE html>
<html class="loading" lang="en" data-textdirection="ltr">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0">
    <title>Add - Docuhealth</title>
@include('admin.layout.header')
<style>
  table td, table th {
    padding: 00.5rem 0.5rem !important;
  }
  .add-market-time-btn{
    position: relative;
    top: 13px;
    float: right;
  }
</style>
    <!-- BEGIN: Content-->
    <div class="app-content content">
      <div class="content-overlay"></div>
      <div class="content-wrapper">
        <div class="content-header row">
        </div>
        <div class="content-body">
<section class="users-list-wrapper">
   <div class="row mt-2">    
    <div class="col-md-12 col-sm-12 dashboard-referral-impression">
      <div class="row">
         <div class="col-md-12 col-12 dashboard-users-success">
          <div class="card">
            <div class="card-body py-1">
              <form method="POST" id="add_data">
                @csrf
                <input type="hidden" name="doctor_id" value="{{$doctor->id}}">
                <div class="row">
                  <div class="col-12">
                    <div class="form-group">
                      <label class="text-bold-600">Name</label>
                      <input type="text" class="form-control" name="name" value="{{$doctor->name}}" placeholder="Enter Name">
                    </div>
                  </div>

                  <div class="col-12"><div class="form-group">
                    <label class="text-bold-600">Specializations</label>
                      <select name="specializations[]" id="specializations" multiple>
                        <option value=""></option>
                        @foreach($specializations as $specialization)
                        <option value="{{$specialization->id}}">{{$specialization->name}}</option>
                        @endforeach
                      </select>
                    </div>
                  </div>

                  <div class="col-3"><div class="form-group">
                    <label class="text-bold-600">Verified</label>
                      <select name="verified" id="verified">

                        @if($doctor->verified == 'Yes')
                        <option value="No">No</option>
                        <option value="Yes" selected>Yes</option>
                        @else
                        <option value="No" selected>No</option>
                        <option value="Yes">Yes</option>
                        @endif
                        
                      </select>
                    </div>
                  </div>
                  <div class="col-3"><div class="form-group">
                    <label class="text-bold-600">Featured</label>
                      <select name="featured" id="featured">
                        @if($doctor->featured == 'Yes')
                        <option value="No">No</option>
                        <option value="Yes" selected>Yes</option>
                        @else
                        <option value="No" selected>No</option>
                        <option value="Yes">Yes</option>
                        @endif
                      </select>
                    </div>
                  </div>

                  <div class="col-3"><div class="form-group">
                    <label class="text-bold-600">Experience Years</label>
                      <select name="experience_years" id="experience_years">
                        <option value="0" selected>0 Year</option>
                        <option value="1">1 Years</option>
                        @for($i=2; $i<15; $i++)
                        <option value="{{$i}}">{{$i}} Years</option>
                        @endfor
                        <option value="15+">15+ Year</option>
                      </select>
                    </div>
                  </div>
                  <div class="col-3"><div class="form-group">
                    <label class="text-bold-600">Experience Months</label>
                      <select name="experience_months" id="experience_months">
                        <option value="0" selected>0 Month</option>
                        <option value="1">1 Month</option>
                        @for($i=2 ; $i<13; $i++)
                        <option value="{{$i}}">{{$i}} Months</option>
                        @endfor
                      </select>
                    </div>
                  </div>

                  <div class="col-6"><div class="form-group">
                    <label class="text-bold-600">Degrees</label>
                      <select name="degrees[]" id="degrees" multiple>
                        @if($doctor->degree)
                          @php $degrees = json_decode($doctor->degree, true) @endphp
                          @for($i=0; $i < sizeof($degrees); $i++)
                            <option value="{{$degrees[$i]}}" selected>{{$degrees[$i]}}</option>
                          @endfor
                        @endif
                      </select>
                    </div>
                  </div>

                  <div class="col-6"><div class="form-group">
                    <label class="text-bold-600">Services</label>
                      <select name="services[]" id="services" multiple>
                        @if($doctor->services)
                          @php $services = json_decode($doctor->services, true) @endphp
                          @for($i=0; $i < sizeof($services); $i++)
                            <option value="{{$services[$i]}}" selected>{{$services[$i]}}</option>
                          @endfor
                        @endif
                      </select>
                    </div>
                  </div>
                    
                  <div class="col-3"><div class="form-group">
                    <label class="text-bold-600">Time From</label>
                      <input type="time" name="time_form" id="time_form" value="{{$doctor->time_from}}" class="form-control">
                    </div>
                  </div>
                  <div class="col-3"><div class="form-group">
                    <label class="text-bold-600">Time To</label>
                      <input type="time" name="time_to" id="time_to" value="{{$doctor->time_to}}" class="form-control">
                    </div>
                  </div>

                  <div class="col-12">
                    <div class="form-group">
                      <label class="text-bold-600">Address</label>
                      <table id="addressTable" style="width:100%;">
                        <tbody>
                          <tr>
                            <td>
                              <textarea class="form-control" name="address[]" placeholder="Enter Full Address" style="min-height: 50px;"></textarea>
                            </td>
                            <td style="width: 10%;" class="text-right">
                              <button type="button" class="btn btn-sm btn-primary" id="add_address_btn">+</button>
                            </td>
                          </tr>
                        </tbody>
                      </table>
                    </div>
                  </div>

                  <div class="col-12">
                    <div class="form-group">
                      <label class="text-bold-600">Description</label>
                      <textarea class="form-control" name="description" value="{{$doctor->description}}" placeholder="Enter Description" style="min-height: 100px;"></textarea>
                    </div>
                  </div>
                    
                </div>
                <div class="mb-1 mt-2" style="float:right;">
                  <button type="reset" class="btn btn-outline-danger mr-1 reset-btn">Cancel</button>
                  <button type="button" class="btn btn-secondary update-btn">Update</button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>
</div></div></div>
<div class="sidenav-overlay"></div>
<div class="drag-target"></div>
@include('admin.layout.footer')
<script>
$(document).ready( function () {

    const doctorID = "{{$doctor_id}}";

    defaultChange = false;
      
    $('#specializations').select2({
      placeholder: "-- select specializations --",
      width:"100%"
    });

    $('#featured').select2({
      placeholder: "-- select featured --",
      width:"100%"
    });

    $('#verified').select2({
      placeholder: "-- select verified --",
      width:"100%"
    });

    $('#experience_years').select2({
      placeholder: "-- select experience year --",
      width:"100%"
    });

    $('#experience_months').select2({
      placeholder: "-- select experience month --",
      width:"100%"
    });

    $('#degrees').select2({
      placeholder: "-- select or add degrees --",
      width:"100%",
      tags: true
    });

    $('#services').select2({
      placeholder: "-- select or add services --",
      width:"100%",
      tags: true
    });


    $('#addressTable').on('click', '#add_address_btn', function() {
        let row = `<tr>
                      <td>
                        <textarea class="form-control" name="address[]" placeholder="Enter Full Address" style="min-height: 50px;"></textarea>
                      </td>
                      <td style="width: 10%;" class="text-right">
                        <button type="button" class="btn btn-sm btn-danger remove-address-btn">-</button>
                      </td>
                    </tr>`;

        $('#addressTable').append(row);
    });

    $('#addressTable').on('click', '.remove-address-btn', function() {
        $(this).closest('tr').remove();
    });

    //create page action function.
    $(document).on('click', '.update-btn', function() {

      //get and set the from data.
      var myform = document.getElementById("add_data");
      var formData = new FormData(myform);
      
      formData.append('_token', '{{ csrf_token() }}');

      $(this).html('Updating...').attr('disabled', true);
      $.ajax({
          type: "post",
          data: formData,
          cache:false,
          contentType: false,
          processData: false,
          url: "{{url('/')}}/{{$auth_path}}/doctors/update",
          success: function(result) {
              $('.update-btn').html('Update').attr('disabled', false);
              if (result.success == false) {
                  Toast.fire({
                    icon: 'error',
                    title: result.message
                  })
              }else{
                  Toast.fire({
                    icon: 'success',
                    title: result.message
                  })
                  $('#add_new').modal('toggle');
                  document.getElementById('add_data').reset();
                  location.replace("{{url('/')}}/{{$auth_path}}/doctors");
              }
          }
      });
    });

    const get_doctor = (id = 0) => {

        $.ajax({
              type: "get",
              url: "{{url('/')}}/{{$auth_path}}/doctors/"+id,
              success: function(result) {
                let data = result.data;

                if (data.specializations) {
                    let specializations = JSON.parse(data.specializations);
                    $('#specializations').val(specializations).trigger('change');
                }

                if (data.clinic_address) {
                  let clinicAddress = JSON.parse(data.clinic_address);
                  let tr = '';

                  for(i in clinicAddress){

                    tr += `<tr>
                            <td>
                              <textarea class="form-control" name="address[]" value="${clinicAddress[i]}" placeholder="Enter Full Address" style="min-height: 50px;"></textarea>
                            </td>`;

                    if (i === 0) {
                      tr += `<td style="width: 10%;" class="text-right">
                              <button type="button" class="btn btn-sm btn-primary" id="add_address_btn">+</button>
                            </td>`;
                    }else{
                      tr += `<td style="width: 10%;" class="text-right">
                              <button type="button" class="btn btn-sm btn-danger remove-address-btn">-</button>
                            </td>`;
                    }

                    tr += `</tr>`;
                  }

                  $('#addressTable').html(tr);
                }
              }
          });
    }

    get_doctor(doctorID);
});
</script>

</body>
</html>