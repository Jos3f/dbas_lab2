// If your node server is on the same server, enable cross-origin resource sharing. Can be done with browser plugin.
// requires jquery

var loggedInAs = 1;
var person_bolongs_to_team = {};
var selectedRoom = 1;
var roomContent = [ // krav på insert room?
  []
];
var peoplenames = {};

// Fill all relevant information about the database
$('document').ready(function() {

  console.log("Js file loaded");

  // load datepicker
  $(function() {
    $("#datepicker").datepicker();
    $("#datepicker").datepicker("option", "dateFormat", "yy-mm-dd");
  });


  // ClockPicker
  $('.clockpicker').clockpicker({
    align: 'left',
    donetext: 'Done'
  });

  // Get all people from the db
  var sql = "SELECT * FROM people";

  // make request with people
  dbRetrive(sql, function(result) {

    var htmlFill = "";
    for (var i = 0; i < result.length; i++) {
      if (result[i].is_active == 1) {
        htmlFill += '<option value=' + result[i].id + '>' + result[i].name + '</option>'
      }
      person_bolongs_to_team[result[i].id] = result[i].team;
      peoplenames[result[i].id] = result[i].name;
    }
    $('#user').html(htmlFill);
    console.log(person_bolongs_to_team);

    htmlFill = "People to add:";
    for (var i = 0; i < result.length; i++) {
      if (result[i].is_active == 1) {
        htmlFill += '<br> <input type="checkbox" id="u' + result[i].name + '" name="pAdd" value="' + result[i].id + '"> <label for="u' + result[i].name + '">' + result[i].name + '</label>'
      }
    }

    $('#addpeople').html(htmlFill);

    sql = "SELECT * FROM meeting_rooms";

    // make request
    dbRetrive(sql, function(result) {

      var htmlFill = "";
      for (var i = 0; i < result.length; i++) {
        roomContent.push([]);
        htmlFill += '<option value=' + result[i].roomID + '>' + result[i].roomID + '</option>'
      }
      $('#room').html(htmlFill);

      sql = "SELECT room, name FROM (has_facility INNER JOIN facilities on has_facility.facility = facilities.facilityID)";
      dbRetrive(sql, function(result) {
        for (var i = 0; i < result.length; i++) {
          roomContent[result[i].room].push(result[i].name);
        }
        var htmlFill = "This room has:";

        for (var i = 0; i < roomContent[selectedRoom].length; i++) {
          htmlFill += '<li>' + roomContent[selectedRoom][i] + '</li>'
        }
        $('.roomPresent').html(htmlFill);
        console.log(roomContent);


        var date = new Date();
        date = date.getUTCFullYear() + '-' +
          ('00' + (date.getUTCMonth() + 1)).slice(-2) + '-' +
          ('00' + date.getUTCDate()).slice(-2) + ' ' +
          ('00' + date.getUTCHours()).slice(-2) + ':' +
          ('00' + date.getUTCMinutes()).slice(-2) + ':' +
          ('00' + date.getUTCSeconds()).slice(-2);
        console.log(date);
        sql = "select * from bookings where time_start >= '" + date + "' Order by time_start";
        dbRetrive(sql, function(res) {
          var htmlFill = "Booked meetings: <br>";

          for (var i = 0; i < res.length; i++) {
            htmlFill += '<input type="radio" name="booking" value=' + res[i].bookingid + '> Room: ' + res[i].room + ' Start time: ' + res[i].time_start + ' Booked by: ' + peoplenames[res[i].booked_by] + ' <br>';
          }
          $('.roomsel').html(htmlFill);
          console.log(roomContent);
        });

      });


    });


  });


});



$(document).on("change", "#user", function() {
  loggedInAs = $('#user').val();
  console.log(loggedInAs);
});

$(document).on("click", "#user_button", function() {
  loggedInAs = $('#user').val();
  console.log(loggedInAs);
});

$(document).on("change", "#room", function() {
  selectedRoom = $('#room').val();

  var htmlFill = "This room has:";

  for (var i = 0; i < roomContent[selectedRoom].length; i++) {
    htmlFill += '<li>' + roomContent[selectedRoom][i] + '</li>'
  }
  if (roomContent[selectedRoom].length == 0) {
    htmlFill = "This room is empty."
  }
  $('.roomPresent').html(htmlFill);
  console.log(selectedRoom);
});

$(document).on("click", "#book_button", function() {
  if (parseInt(($("#start_time").val()).slice(0, 2)) < parseInt(($("#end_time").val()).slice(0, 2)) || (parseInt(($("#start_time").val()).slice(0, 2)) == parseInt(($("#end_time").val()).slice(0, 2))) && (parseInt(($("#start_time").val()).slice(3, 5)) < parseInt(($("#end_time").val()).slice(3, 5)))) {
    console.log("dat time tho");
    // console.log(($("#datepicker").datepicker("getDate")).toISOString().slice(0,10).replace(/-/g,"-"));
    var req1 = "SELECT count(room) count FROM bookings WHERE " + "'" + ($("#datepicker").datepicker("getDate")).toISOString().slice(0, 10).replace(/-/g, "-") + " " + document.getElementById("end_time").value + "'" + " >= time_start AND " + "'" + ($("#datepicker").datepicker("getDate")).toISOString().slice(0, 10).replace(/-/g, "-") + " " + document.getElementById("start_time").value + "'" + "<= time_end and room = " + selectedRoom;

    dbRetrive(req1, function(result) {
      // make sure to add checked people to the meetings.
      if (result[0].count != 0) {
        $('.message').html("Error: Overlapping booking. Select another room or time");
        $('.message').css('display', 'block');
      } else {
        var sqlcost = "SELECT sum(cost_per_hour) cost FROM facilities JOIN has_facility ON has_facility.facility = facilities.facilityid WHERE room = " + selectedRoom;
        dbRetrive(sqlcost, function(costResult) {
          console.log(costResult);
          $('.message').css('display', 'none');
          var req = "INSERT INTO `bookings` (`room`, `time_start`, `time_end`, `booked_by`,`booked_by_team`,cost) VALUES (" + selectedRoom + ", '" + ($("#datepicker").datepicker("getDate")).toISOString().slice(0, 10).replace(/-/g, "-") + " " + document.getElementById("start_time").value + "'," + "'" + ($("#datepicker").datepicker("getDate")).toISOString().slice(0, 10).replace(/-/g, "-") + " " + document.getElementById("end_time").value + "'" + ", " + loggedInAs + "," + person_bolongs_to_team[loggedInAs] + ", " + costResult[0].cost * timediff(document.getElementById("start_time").value, document.getElementById("end_time").value) + ")";
          dbRetrive(req, function(res) {
            console.log(res);
            // make sure to add checked people to the meetings.
            var sql2 = "INSERT INTO `meeting_participants` (`booking`, `participant`) VALUES "
            var participantExists = false;
            $("input:checkbox[name=pAdd]:checked").each(function() {
              sql2 += "(" + res.insertId + "," + $(this).val() + "),"
              console.log($(this).val());
              participantExists = true;
            });
            sql2 = sql2.slice(0, -1);
            console.log(sql2);

            if (participantExists) {
              dbRetrive(sql2, function(lol) {
                location.reload();
              });
            } else {
              location.reload();
            }

          });
        });

      }
      console.log(result);
    });
  } else {
    $(".message").html("Error: check the time interval.");
    $('.message').css('display', 'block');
  }

  console.log("hah");
});

$(document).on("click", "#remove_button", function() {
  console.log($('input[name="booking"]:checked').val());
  var sql = "delete from bookings where bookingid = " + $('input[name="booking"]:checked').val() + " AND booked_by = " + loggedInAs;
  if ($('input[name="booking"]:checked').val() == undefined) {
    $(".message").html("ERROR: Plz select a room 2 remove");
    $('.message').css('display', 'block');
  } else {
    dbRetrive(sql, function(res) {
      if (res.affectedRows == 0) {
        $(".message").html("U cant remove this meeting");
        $('.message').css('display', 'block');
      } else {
        var sql3 = "delete from meeting_participants where booking = " + $('input[name="booking"]:checked').val();
        dbRetrive(sql3, function() {
          location.reload();
        });


      }
      console.log(res);
    });
  }

});


// request made with object as input
// Returns the result as JSON
// TODO: Fix asyncronous problem with _callback.
function dbRetrive(requestObject, _callback) {
  console.log("recieved");
  xmlhttp = new XMLHttpRequest();
  xmlhttp.open("POST", "http://localhost:8001/", true);
  xmlhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
  xmlhttp.onreadystatechange = function() {
    if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
      result = xmlhttp.responseText;
      // print and return result
      console.log(result);
      // $('.result').html(result);

      _callback(JSON.parse(result));
    }
  }
  xmlhttp.send(requestObject);
}

// Calculate difference in hours between two datestamps
function timediff(start, finish) {
  var hours = parseInt(finish.slice(0, 2)) - parseInt(start.slice(0, 2));

  hours += (parseInt(finish.slice(3, 5)) - parseInt(start.slice(3, 5))) / 60;

  return hours;
}
