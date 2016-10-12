# Ticket Checking ####################################################################################################
library(rPython)
python.exec('import sys')
python.exec("sys.path.append('/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages')")
# python.assign("plate_number","4222GE")
python.load('Desktop/prj2/violation_check.py')
python.call('Ticket_check',"4222GE")

server = function(input, output, session){
  output$out1 <- renderPrint({
    python.call('Ticket_check',input$plate_number)
  })
}
