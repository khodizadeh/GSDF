Function selectedFinalSim2(DS As Double, GS As Double, LV As Double) As Double

    If DS > GS Then
        Mx = DS
        Mn = GS
    Else
        Mx = GS
        Mn = DS
    End If
    
    T = (Mx * 0.7 + Mn * 0.3)
    
    If T > 0.6 Then
        If LV > T Then
            selectedFinalSim2 = T * 0.5 + LV * 0.5
        Else
            selectedFinalSim2 = T * 0.9 + LV * 0.1
        End If
    Else
        selectedFinalSim2 = T * 0.7 + LV * 0.3
    End If
    
    
End Function
