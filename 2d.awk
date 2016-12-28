##########
# vars
#  xSize: horizontal size of graph
#  ySize: vertical size of graph
#  type: type of graph (bar or default of plot)
#  horizTitle: horizontal title of graph
#  vertTitle: vertical title of graph
#  dataPoints: number of data points to be graphed
#  horizVal[x]: array of horizontal data points
#  vertVal[y]: array of vertical data points
#  datapointWidth: horizontal size of each datapoint, scale value, when width of graphs is larger than number of data points
#  datapointHeight: vertical size of each datapoint, scale value
#  graph[x, y]: array of size xSize, ySize that contains plotted values

function round(x) {
  fraction = x - int(x)
  if (fraction > 0.5) {
    return int(x) + 1
  } else {
    return int(x)
  }
}

function readFirstLine() {
  maxVVal = $2
  minVVal = $2
  dataPoints = NF - 1
  #print "dataPoints: " dataPoints
  horizTitle = $1
  for (count = 0; count < dataPoints; count++) {
    horizVal[count] = $(count + 2)
    if ($(count + 2) > maxVVal) {
      maxVVal = $(count + 2)
    }
    if ($(count + 2) < minVVal) {
      minVVal = $(count + 2)
    }
  }
}

function readSecondLine() {
  for (count = 0; count < dataPoints; count++) {
    vertVal[count] = $(count + 2)
    #print "adding " $(count + 2) " to " sum
    sum += $(count + 2)
    if ($(count + 2) > maxHVal) {
      maxHVal = $(count + 2)
    }
    if ($(count + 2) < minHVal) {
      minHVal = $(count + 2)
    }
  }
}

function initArray() {
  # init array that will contain graph
  for (hCount = 0; hCount <= xSize; hCount++) {
    for (vCount = 0; vCount <= ySize; vCount++) {
      #print "hCount: " hCount
      #print "vCount: " vCount
      graph[hCount, vCount] = "."
    }
  }
}

function fillArray() {
  # plot each data point
  for (count = 0; count < dataPoints; count++ ) {
    hVal = (horizVal[count] * xSize / (maxVVal - minVVal + 1)) - (xSize / (maxVVal - minVVal) * minVVal)
    if (hVal < 0) { hVal = -hVal }
    vVal = (vertVal[count] * ySize / (maxHVal - minHVal + 1)) - (ySize / (maxHVal - minHVal) * minHVal)
    if (vVal < 0) { vVal = -vVal }
    #print "original datapoint " horizVal[count] "," vertVal[count] " becomes " hVal "," vVal " after scaling and " round(hVal) "," round(vVal) " after rounding function"
    hVal = round(hVal)
    vVal = round(vVal)

    graph[hVal, vVal] = "*"
    # if the graph type is a bar graph we need to fill in
    # the bar
    if (type == "bar") {
      for (countBar = 0; countBar < vVal; countBar++) {
        graph[hVal, countBar] = "*"
      }
    }
  }
}

function usage() {
  print ""
  print "error: must supply xSize and ySize of graph"
  print "e.g. awk -v xSize=40 -v ySize=15 -f 2d.awk"
  print ""
}

BEGIN {
  lineCount = 0
  FS=","
  sum = 0
  if (xSize == "" || ySize == "") {
    usage()
    exit 1
  }
  type="bar"
}
{
  if (lineCount == 0) {
    readFirstLine()
  }

  if (lineCount > 0) {
    maxHVal = $2
    minHVal = $2
    vertTitle = $1
    #print "vertTitle: " vertTitle

    readSecondLine()

    #print "sum of data points: " sum
    avg = sum / dataPoints
    #print "avg of data points: " avg
    print "xSize: " xSize
    print "ySize: " ySize
    print "maxHVal: " maxHVal
    print "minHVal: " minHVal
    print "maxVVal: " maxVVal
    print "minVVal: " minVVal
    datapointWidth = xSize / dataPoints
    datapointHeight = ySize / (maxHVal - minHVal + 1)
    print "datapointWidth: " datapointWidth
    print "datapointHeight: " datapointHeight

    initArray()
    fillArray()
  }

  lineCount++
}
END {
  # display array containing graph
  #for (vCount = ySize; vCount >= 0; vCount--) {
    #for (hCount = 0; hCount <= xSize; hCount++) {
      #printf("%s", graph[hCount, vCount])
    #}
    #printf("\n")
  #}

  # build vertical scale that will be displayed
  # to the left of the graph
  pointScale = (maxHVal - minHVal + 1) / ySize
  #print "pointScale: " pointScale
  for (count = 0; count <= ySize; count++) {
    #print "vertScale[" count + 1 "]: " int(minHVal + (pointScale * count))
    vertScale[count] = round(minHVal + (pointScale * count))
    if (vertScale[count] > maxHVal) {
      vertScale[count] = maxHVal
    }
  }

  # build horizontal scale that will be displayed
  # underneath the graph
  pointScale = (maxVVal - minVVal + 1) / xSize
  #print "pointScale: " pointScale
  for (count = 0; count <= xSize; count++) {
    #print "horizScale[" count + 1 "]: " int(minVVal + (pointScale * count))
    horizScale[count] = round(minVVal + (pointScale * count))
    if (horizScale[count] > maxVVal) {
      horizScale[count] = maxVVal
    }
  }

  # how many characters does the largest digit occupy?
  # needed for correct formatting
  numHDigits = length(maxHVal + "")
  #print "numDigits of value " maxHVal ": " numHDigits

  # how many characters does the largest digit occupy?
  # needed for correct formatting
  numVDigits = length(maxVVal + "")
  #print "numDigits of value " maxVVal ": " numVDigits

  # figure out how long the title that will be displayed
  # horizontally at the bottom of the graph is
  horizTitleLength = length(horizTitle)
  #print "length of " horizTitle ": " horizTitleLength

  # figure out how long the title that will be displayed
  # vertically to the left of the graph is
  vertTitleLength = length(vertTitle)
  #print "length of " vertTitle ": " vertTitleLength

  # determine where to place the text so it is in the middle
  vertTextStart = ySize - (int(ySize / 2) - int(vertTitleLength / 2)) + 1
  #print "start vertical text at position: " vertTextStart

  # determine where to place the text so it is in the middle
  horizTextStart = int(xSize / 2) - int(horizTitleLength / 2)
  #print "start horizontal text at position: " horizTextStart

  # place the vertical title into an array, one character
  # at a time
  for (count = ySize; count >= 0; count--) {
    if ((count < vertTextStart) && (count >= vertTextStart - length(vertTitle))) {
      yTitle[count] = substr(vertTitle, vertTextStart - count, 1)
    } else {
      yTitle[count] = " "
    }
  }

  # display overall array
  for (vCount = ySize; vCount >= 0; vCount--) {
    printf("%c %" numHDigits "d|", yTitle[vCount], vertScale[vCount])
    for (hCount = 0; hCount <= xSize; hCount++) {
      printf("%s", graph[hCount, vCount])
    }
    printf("\n")
  }

  # place the horizontal title into an array, one character
  # at a time
  for (count = 0; count <= xSize; count++) {
    if ((count > horizTextStart) && (count <= horizTextStart + length(horizTitle))) {
      xTitle[count] = substr(horizTitle, count - horizTextStart, 1)
    } else {
      xTitle[count] = " "
    }
  }

  # create scale for placement along the bottom
  # scale values will be listed vertically
  for (count = 0; count <= xSize; count++) {
    for (digit = 0; digit < numVDigits; digit++) {
      #print "examining horizScale[" count "]: " horizScale[count]
      #print "length of horizScale[" count "]: " length(horizScale[count])
      #print "count: " count " digit: " digit
      if (length(horizScale[count]) >= digit + 1) {
        #print "long enough"
        xLegend[count, digit + 1] = substr(horizScale[count], digit + 1, 1)
      } else {
        #print "too short"
        xLegend[count, digit + 1] = " "
      }
      #print "xLegend[" count "," digit + 1 "]: " xLegend[count, digit + 1]
    }
  }

  # display scale along bottom
  # but first add padding according to how far shifted to right
  # the graph is
  for (digit = 0; digit < numVDigits; digit++) {
    for (pad = 1; pad <= 3 + numHDigits; pad++) {
      printf(" ")
    }
    for (count = 0; count <= xSize; count++) {
      printf("%s", xLegend[count, digit + 1])
    }
    printf("\n")
  }

  # display title along bottom
  # but first add padding according to how far shifted to right
  # the graph is
  for (count = 1; count <= 2 + numHDigits; count++) {
    printf(" ")
  }
  for (count = 1; count <= xSize; count++) {
    printf("%s", xTitle[count])
  }
  printf("\n")
}
