var data;
var options;
var chart;

google.load('visualization', '1.0', {'packages':['corechart']});
        
function createChart(title, number, answers, counts, onSuccess, onFailure) {
    try {
      // Create the data table.
      data = new google.visualization.DataTable();
      data.addColumn('string');
      data.addColumn('number');
      for(var i=0;i<number;i++)
        data.addRows([[answers[i], counts[i]]]);
      
      // Set chart options
      options = {'title':title,
                 'height':300};

      // Instantiate and draw our chart, passing in some options.
      chart = new google.visualization.PieChart(document.getElementById('chart'));
      chart.draw(data, options);
      onSuccess('OK');
    }
    catch(e) {
      onFailure(e);
    }
    
}