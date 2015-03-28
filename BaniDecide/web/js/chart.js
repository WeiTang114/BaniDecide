var data;
var options;
var chart;

function createChart(answers,counts,number,title)//onSuccess,onFail)
{

    //console.log('success!');
        google.load('visualization', '1.0', {'packages':['corechart']});

        // Set a callback to run when the Google Visualization API is loaded.
        google.setOnLoadCallback(drawChart);

        // Callback that creates and populates a data table,
        // instantiates the pie chart, passes in the data and
        // draws it.
        function drawChart() {

          // Create the data table.
          data = new google.visualization.DataTable();
          data.addColumn('string');
          data.addColumn('number');
          for(var i=0;i<number;i++)
            data.addRows([[answers[i], counts[i]]]);
          
          // Set chart options
          options = {'title':title,
                       'width':400,
                       'height':300};

          // Instantiate and draw our chart, passing in some options.
          chart = new google.visualization.PieChart(document.getElementById('chart_div'));
          chart.draw(data, options);
          console.log(data);
        }
    
}