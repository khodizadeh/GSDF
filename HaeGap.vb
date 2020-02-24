Function haveGap(idAir As Long, idDbp As Long)
    Dim DB As Database
    Dim qd1, qd2 As QueryDef
    Dim RST, dst As Recordset
    
    
        
    Set qd1 = CurrentDb().QueryDefs("airdbpCountryLocInfo")
    
    qd1!airID = idAir
    qd1!dbpID = idDbp
    
    Set RST = qd1.OpenRecordset
    
    Dim c1, c2 As String
    
 
    If c1 = c2 Then
        haveGap = False
        Exit Function
    End If
    
    
        
    Set qd2 = CurrentDb().QueryDefs("NeighbourCheck")
    
    qd2!airID = idAir
    qd2!dbpID = idDbp
    
    Set dst = qd2.OpenRecordset
    
    If dst.EOF Then
        haveGap = True
        Exit Function
    End If
    
    

    
    If Abs(RST("airLat") - RST("dbpLat")) > 1 Then
        haveGap = True
        Exit Function
    Else
    
  
       If calcGeoDistance(CDbl(RST("airLat")), CDbl(RST("airLng")), CDbl(RST("dbpLat")), CDbl(RST("dbpLng"))) > 150 Then
                haveGap = True
                Exit Function
       End If
       
    End If
    
    
   
 
   haveGap = False


End Function