          { Copyright (C) 2025  StOver }
          {$CODEPAGE UTF8}
Unit
          alignComponentsImpl;

          {$mode objfpc}{$H+}

Interface


Procedure
          Register;

implementation

Uses
          Classes,
          SysUtils,
          Controls,
          Forms,
          Dialogs,
          menuintf,
          IDECommands,
          ToolBarIntf,
          FormEditingIntf,
          propedits,
          lcltype;

          {$R alignComponents_images.res}

Const
          // first selected component rules
          SALIGN_LFT                        = 'align_left';
          SALIGN_RGT                        = 'align_right';
          SALIGN_TOP                        = 'align_top';
          SALIGN_BTM                        = 'align_bottom';

          // lowest/highest value rules
          SALIGN_LFT_MST                    = 'align_leftmost';
          SALIGN_RGT_MST                    = 'align_rightmost';
          SALIGN_TOP_MST                    = 'align_topmost';
          SALIGN_BTM_MST                    = 'align_bottommost';

          // size
          // as first
          SALIGN_SZE_HGT                    = 'align_height';
          SALIGN_SZE_WTH                    = 'align_width';

          // as highest, lowest, widest, smalles
          SALIGN_SZE_HST                    = 'align_highest';
          SALIGN_SZE_LST                    = 'align_lowest';
          SALIGN_SZE_WST                    = 'align_widest';
          SALIGN_SZE_SST                    = 'align_smallest';

Resourcestring

          SALIGN_LFT_IDEMenuCaption         = 'Nach links ausrichten';
          SALIGN_RGT_IDEMenuCaption         = 'Nach rechts ausrichten';
          SALIGN_TOP_IDEMenuCaption         = 'Nach oben ausrichten';
          SALIGN_BTM_IDEMenuCaption         = 'Nach unten ausrichten';

          SALIGN_LFT_MST_IDEMenuCaption     = 'Nach linkster ausrichten';
          SALIGN_RGT_MST_IDEMenuCaption     = 'Nach rechtester ausrichten';
          SALIGN_TOP_MST_IDEMenuCaption     = 'Nach oberster ausrichten';
          SALIGN_BTM_MST_IDEMenuCaption     = 'Nach unterster ausrichten';

          SALIGN_SMH_IDEMenuCaption         = 'Höhe angleichen';             // same height (like first selected)
          SALIGN_SMW_IDEMenuCaption         = 'Breite angleichen';           // same width  (like first selected)

          SALIGN_HST_IDEMenuCaption         = 'Am höchsten ausrichten';
          SALIGN_LST_IDEMenuCaption         = 'Am niedrigsten ausrichten';
          SALIGN_WST_IDEMenuCaption         = 'Am breitesten ausrichten';
          SALIGN_SST_IDEMenuCaption         = 'Am schmalsten ausrichten';

Type
          tCompDim                          = ( cpdLeft , cpdTop);
          tCtrlDim                          = ( ctdRight, ctdBottom, ctdHeight, ctdWidth);
          tHgtWthMinOrMax                   = ( hwNone  , hwMin   , hwMax);

          { tHelpObj }

          tHelpObj                          = Class( tObject)

             pslCurSelComps                 : tPersistentSelectionList;
             pslCurSelCtrls                 : tPersistentSelectionList;

             Function                       getNonFormSelection( Const aSelection: tPersistentSelectionList): tPersistentSelectionList;
             Function                       getControlSelection(): tPersistentSelectionList;
             Procedure                      PropHookSetSelection( Const aSelection: tPersistentSelectionList);

             Procedure                      xAbleOne( aCmd: tIDEMenuCommand; aEnable: Boolean);
             Procedure                      xAbleCommands( aCmds: Array Of tIDEMenuCommand; aEnable: Boolean); Overload;
             Procedure                      xAbleCommands( aCompSel: intEger; aCtrlSel: intEger); Overload;

             Function                       refreshPSLists( Const aSelection: tPersistentSelectionList): boolEAN;
             Procedure                      refreshCmdsXablation( Const aSelection: tPersistentSelectionList);

             Procedure                      tryRefreshLUR();

             Procedure                      alignTopOrLeft( aCompDim: tCompDim; aTemplIdx: intEger= 0);
             Procedure                      alignLeft( aSender: tObject);
             Procedure                      alignTop( aSender: tObject);

             Function                       checkCompSelection(): boolEan;
             Function                       checkCompSelectionAndIndex( aInTemplIdx: intEger; Out aOutTemplIdx: intEger): boolEan;

             Function                       getldxOfCompWthSmllstDimValue( aCompDim: tCompDim): intEger;

             Function                       checkCtrlSelection(): boolEan;
             Function                       checkCtrlSelectionAndIndex( aInTemplIdx: intEger; Out aOutTemplIdx: intEger): boolEan;

             Procedure                      alignLeftMost( aSender: tObject);
             Procedure                      alignTopMost( aSender: tObject);

             Procedure                      alignRightOrBottom( aCtlDim: tCtrlDim; aTemplIdx: intEger= 0); Overload;
             Procedure                      alignRightOrBottom( aSender: tObject; aCtlDim: tCtrlDim; aSpec: tHgtWthMinOrMax= hwNone); Overload;

             Procedure                      alignRight( aSender: tObject);
             Procedure                      alignBottom( aSender: tObject);

             Procedure                      ctrlDimHlper( aCtrlIdx: intEger; aCtlDim: tCtrlDim; aSpec: tHgtWthMinOrMax; Var aVarResIdx: intEger; Var aVarMostVal: intEger);
             Function                       getldxOfCtrlWthSpecDimValue( aCtlDim: tCtrlDim; aSpec: tHgtWthMinOrMax= hwNone): intEger;

             Procedure                      alignRightMost( aSender: tObject);
             Procedure                      alignBottomMost( aSender: tObject);

             Procedure                      alignHeightOrWidth( aCtlDim: tCtrlDim; aTemplIdx: intEger= 0);

             Procedure                      alignHeight( aSender: tObject);
             Procedure                      alignWidth( aSender: tObject);

             Procedure                      alignXest( aSender: tObject; aCtlDim: tCtrlDim; aSpec: tHgtWthMinOrMax= hwNone);

             Procedure                      alignHighest( aSender: tObject);
             Procedure                      alignLowest( aSender: tObject);

             Procedure                      alignWidest( aSender: tObject);
             Procedure                      alignSmallest( aSender: tObject);


          Public

             Constructor                    create();
          End;


Var
          imcCmd_LFT                        : tIDEMenuCommand= Nil;
          imcCmd_RGT                        : tIDEMenuCommand= Nil;
          imcCmd_TOP                        : tIDEMenuCommand= Nil;
          imcCmd_BTM                        : tIDEMenuCommand= Nil;

          imcCmd_LFT_MST                    : tIDEMenuCommand= Nil;
          imcCmd_RGT_MST                    : tIDEMenuCommand= Nil;
          imcCmd_TOP_MST                    : tIDEMenuCommand= Nil;
          imcCmd_BTM_MST                    : tIDEMenuCommand= Nil;

          imcCmd_SZE_HGT                    : tIDEMenuCommand= Nil;   //
          imcCmd_SZE_WTH                    : tIDEMenuCommand= Nil;   //

          imcCmd_SZE_HST                    : tIDEMenuCommand= Nil;   // highest
          imcCmd_SZE_LST                    : tIDEMenuCommand= Nil;   // lowest
          imcCmd_SZE_WST                    : tIDEMenuCommand= Nil;   // widest
          imcCmd_SZE_SST                    : tIDEMenuCommand= Nil;   // smallest

          {$hints off}
          ho_Obj: tHelpObj                  = Nil;

Procedure
          nOp( aSender: tObject);
Begin

End;
          {$hints on}

Function
          registerOneCmd( aCmdId: String; aCmdCaption: String; aObjMthd: tNotifyEvent): tIDEMenuCommand;
Var
          Key                               : tIDEShortCut;
          Cat                               : tIdeCommandCategory;
          Cmd                               : tIdeCommand;
Begin
          Result:= Nil;

          Try
             Key:= IDEShortCut( vk_unknown, []);
             Cat:= IDECommandList.FindCategoryByName( CommandCategoryToolMenuName);

             Cmd:= RegisterIDECommand( Cat, aCmdId, aCmdCaption, Key, aObjMthd, Nil);
             RegisterIDEButtonCommand( Cmd);
             Result:= RegisterIDEMenuCommand( itmSecondaryTools, aCmdId, aCmdCaption, aObjMthd, Nil, Cmd, AnsiLowerCase( aCmdId));

          Except End;
End;

Procedure
          Register;
Begin
          If not assigned( GlobalDesignHook)
             Then
             Exit;

          // first comp in list defines
          imcCmd_LFT    := registerOneCmd( SALIGN_LFT    , SALIGN_LFT_IDEMenuCaption    , @ho_Obj.alignLeft);
          imcCmd_TOP    := registerOneCmd( SALIGN_TOP    , SALIGN_TOP_IDEMenuCaption    , @ho_Obj.alignTop);
          imcCmd_RGT    := registerOneCmd( SALIGN_RGT    , SALIGN_RGT_IDEMenuCaption    , @ho_Obj.alignRight);
          imcCmd_BTM    := registerOneCmd( SALIGN_BTM    , SALIGN_BTM_IDEMenuCaption    , @ho_Obj.alignBottom);

          // "most" value of selected
          imcCmd_LFT_MST:= registerOneCmd( SALIGN_LFT_MST, SALIGN_LFT_MST_IDEMenuCaption, @ho_Obj.alignLeftMost);
          imcCmd_TOP_MST:= registerOneCmd( SALIGN_TOP_MST, SALIGN_TOP_MST_IDEMenuCaption, @ho_Obj.alignTopMost);
          imcCmd_RGT_MST:= registerOneCmd( SALIGN_RGT_MST, SALIGN_RGT_MST_IDEMenuCaption, @ho_Obj.alignRightMost);
          imcCmd_BTM_MST:= registerOneCmd( SALIGN_BTM_MST, SALIGN_BTM_MST_IDEMenuCaption, @ho_Obj.alignBottomMost);

          // size of controls (height, width)
          // first selected
          imcCmd_SZE_HGT:= registerOneCmd( SALIGN_SZE_HGT, SALIGN_SMH_IDEMenuCaption    , @ho_Obj.alignHeight);
          imcCmd_SZE_WTH:= registerOneCmd( SALIGN_SZE_WTH, SALIGN_SMW_IDEMenuCaption    , @ho_Obj.alignWidth);

          // max/min dim (highest, lowest, widest, smalles)
          imcCmd_SZE_HST:= registerOneCmd( SALIGN_SZE_HST, SALIGN_HST_IDEMenuCaption    , @ho_Obj.alignHighest);
          imcCmd_SZE_LST:= registerOneCmd( SALIGN_SZE_LST, SALIGN_LST_IDEMenuCaption    , @ho_Obj.alignLowest);
          imcCmd_SZE_WST:= registerOneCmd( SALIGN_SZE_WST, SALIGN_WST_IDEMenuCaption    , @ho_Obj.alignWidest);
          imcCmd_SZE_SST:= registerOneCmd( SALIGN_SZE_SST, SALIGN_SST_IDEMenuCaption    , @ho_Obj.alignSmallest);

          GlobalDesignHook.AddHandlerSetSelection( @ho_Obj.PropHookSetSelection);

End;

{ tHelpObj }

Function
          tHelpObj.getNonFormSelection( Const aSelection: tPersistentSelectionList): tPersistentSelectionList;
Var
          vIn1                              : intEger;
          vIn2                              : intEger;
Begin
          Result:= tPersistentSelectionList.Create();

          If assigned( aSelection)
             Then
             Begin
                  vIn2:= aSelection.Count;
                  For vIn1:= 0 To vIn2- 1
                      Do
                      Begin
                           If ( aSelection[ vIn1] is tComponent)
                              And
                              Not ( aSelection[ vIn1] is tCustomForm)
                              Then
                              Result.Add( aSelection[ vIn1]);
                  End;

          End;
End;

Function
          tHelpObj.getControlSelection(): tPersistentSelectionList;
Var
          vIn1                              : intEger;
          vIn2                              : intEger;
Begin
          Result:= tPersistentSelectionList.Create();

          If assigned( pslCurSelComps)
             Then
             Begin
                  vIn2:= pslCurSelComps.Count;
                  For vIn1:= 0 To vIn2- 1
                      Do
                      Begin
                           If ( pslCurSelComps[ vIn1] is tControl)
                              And
                              Not ( pslCurSelComps[ vIn1] is tCustomForm)
                              Then
                              Result.Add( pslCurSelComps[ vIn1]);
                  End;
          End;
End;

Procedure
          tHelpObj.xAbleOne( aCmd: tIDEMenuCommand; aEnable: Boolean);
Begin
          If assigned( aCmd)
             Then
             aCmd.Enabled:= aEnable;
End;

Procedure
          tHelpObj.xAbleCommands( aCmds: Array Of tIDEMenuCommand; aEnable: Boolean);
Var
          vIn1                              : intEger;
          vIn2                              : intEger;
Begin
          vIn2:= length( aCmds);
          For vIn1:= 0 To vIn2- 1
              Do
              xAbleOne( aCmds[ vIn1], aEnable);
End;

Procedure
          tHelpObj.xAbleCommands( aCompSel: intEger; aCtrlSel: intEger);
Begin
          xAbleCommands(
                        [
                         imcCmd_LFT    , imcCmd_RGT    , imcCmd_TOP    , imcCmd_BTM    ,
                         imcCmd_LFT_MST, imcCmd_RGT_MST, imcCmd_TOP_MST, imcCmd_BTM_MST,
                         imcCmd_SZE_HGT, imcCmd_SZE_WTH,
                         imcCmd_SZE_HST, imcCmd_SZE_LST, imcCmd_SZE_WST, imcCmd_SZE_SST
                        ],
                        False
          );

          If ( aCompSel> 1)
             Then
             Begin
                  xAbleCommands( [ imcCmd_LFT, imcCmd_TOP, imcCmd_LFT_MST, imcCmd_TOP_MST], True);

                  If ( aCompSel= aCtrlSel)
                     Then
                     Begin
                          xAbleCommands(
                                        [
                                         imcCmd_RGT    , imcCmd_BTM    ,
                                         imcCmd_RGT_MST, imcCmd_BTM_MST,
                                         imcCmd_SZE_HGT, imcCmd_SZE_WTH,
                                         imcCmd_SZE_HST, imcCmd_SZE_LST, imcCmd_SZE_WST, imcCmd_SZE_SST
                                        ],
                                        True
                          );
                  End;
          End;
End;

Function
          tHelpObj.refreshPSLists( Const aSelection: tPersistentSelectionList): boolEAN;
Begin
          Result:= False;

          pslCurSelComps:= getNonFormSelection( aSelection);
          pslCurSelCtrls:= Nil;

          If assigned( pslCurSelComps)
             Then
             Begin
                  pslCurSelCtrls:= getControlSelection();
                  Result:= assigned( pslCurSelCtrls);
          End;
End;

Procedure
          tHelpObj.refreshCmdsXablation( Const aSelection: tPersistentSelectionList);
Var
          vInCmps                           : intEger;
          vInCtrs                           : intEger;
Begin
          xAbleCommands( 0, 0);

          If refreshPSLists( aSelection)
             Then
             Begin
                  vInCmps:= pslCurSelComps.Count;
                  vInCtrs:= pslCurSelCtrls.Count;

                  xAbleCommands( vInCmps, vInCtrs)
          End;
End;


Procedure
          tHelpObj.PropHookSetSelection( Const aSelection: tPersistentSelectionList);
Begin
          refreshCmdsXablation( aSelection);
End;

Procedure
          tHelpObj.tryRefreshLUR();
Begin
          If not assigned( GlobalDesignHook)
             Then
             Exit;

          Try
             If assigned( GlobalDesignHook.LookupRoot)
                And
                ( GlobalDesignHook.LookupRoot Is tControl)
                Then
                tControl( GlobalDesignHook.LookupRoot).rePaint()
          Except End;
End;

Function
          tHelpObj.checkCompSelection(): boolEan;
Begin
          Result      := False;

          If Not assigned( pslCurSelComps)
             Then
             Exit;

          If ( pslCurSelComps.Count< 2)
             Then
             Exit;

          Result:= True;
End;


Function
          tHelpObj.checkCompSelectionAndIndex( aInTemplIdx: intEger; Out aOutTemplIdx: intEger): boolEan;
Begin
          Result      := checkCompSelection();
          aOutTemplIdx:= 0;

          If Not Result
             Then
             Exit;

          If ( -1< aInTemplIdx)
             And
             ( pslCurSelComps.Count> aInTemplIdx)
             Then
             aOutTemplIdx:= aInTemplIdx;

          Result:= True;
End;


Function
          tHelpObj.getldxOfCompWthSmllstDimValue( aCompDim: tCompDim): intEger;
Var
          vInMost                           : intEger;
          vInLftC                           : intEger;
          vInTopC                           : intEger;
          vIn1                              : intEger;
          vIn2                              : intEger;
Begin
          Result:= -1;
          If Not checkCompSelection()
             Then
             Exit;

          Try
             vInMost:= MaxInt;
             vIn2:= pslCurSelComps.Count;

             For vIn1:= 0 To vIn2- 1
                 Do
                 Begin
                      GetComponentLeftTopOrDesignInfo( tComponent( pslCurSelComps[ vIn1]), vInLftC, vInTopC);

                      If ( aCompDim= cpdLeft) And ( vInLftC< vInMost)
                         Then
                         Begin
                              vInMost:= vInLftC;
                              Result:= vIn1;
                      End;

                      If ( aCompDim= cpdTop ) And ( vInTopC< vInMost)
                         Then
                         Begin
                              vInMost:= vInTopC;
                              Result:= vIn1;
                      End;

             End;
          Except End;
End;

Procedure
          tHelpObj.alignTopOrLeft( aCompDim: tCompDim; aTemplIdx: intEger= 0);
Var
          vInTIx                            : intEger;
          vInLft                            : intEger;
          vInTop                            : intEger;
          vInLftC                           : intEger;
          vInTopC                           : intEger;
          vIn1                              : intEger;
          vIn2                              : intEger;
Begin
          If Not checkCompSelectionAndIndex( aTemplIdx, vInTIx)
             Then
             Exit;

          Try
             GetComponentLeftTopOrDesignInfo( tComponent( pslCurSelComps[ vInTIx]), vInLft, vInTop);

             vIn2:= pslCurSelComps.Count;

             For vIn1:= 0 To vIn2- 1
                 Do
                 Begin
                      If ( vInTIx<> vIn1)
                         Then
                         Begin
                              GetComponentLeftTopOrDesignInfo( tComponent( pslCurSelComps[ vIn1]), vInLftC, vInTopC);

                              If ( aCompDim= cpdLeft)
                                 Then
                                 SetComponentLeftTopOrDesignInfo( tComponent( pslCurSelComps[ vIn1]), vInLft, vInTopC)
                              Else
                                 SetComponentLeftTopOrDesignInfo( tComponent( pslCurSelComps[ vIn1]), vInLftC, vInTop)
                      End;
             End;
             tryRefreshLUR();

          Except End;
End;


Procedure
          tHelpObj.alignLeft( aSender: tObject);
Begin
          nOp( aSender);
          alignTopOrLeft( cpdLeft);
End;

Procedure
          tHelpObj.alignTop( aSender: tObject);
Begin
          nOp( aSender);
          alignTopOrLeft( cpdTop);
End;

Procedure
          tHelpObj.alignLeftMost( aSender: tObject);
Var
          vInTmplIdx                        : intEger;
Begin
          nOp( aSender);
          vInTmplIdx:= getldxOfCompWthSmllstDimValue( cpdLeft);

          If ( -1< vInTmplIdx)
             Then
             alignTopOrLeft( cpdLeft, vInTmplIdx);
End;

Procedure
          tHelpObj.alignTopMost( aSender: tObject);
Var
          vInTmplIdx                        : intEger;
Begin
          nOp( aSender);

          vInTmplIdx:= getldxOfCompWthSmllstDimValue( cpdTop);
          If ( -1< vInTmplIdx)
             Then
             alignTopOrLeft( cpdTop, vInTmplIdx);
End;

Function
          tHelpObj.checkCtrlSelection(): boolEan;
Begin
          Result      := False;

          If Not assigned( pslCurSelCtrls)
             Then
             Exit;

          If ( pslCurSelCtrls.Count< 2)
             Then
             Exit;

          Result:= True;
End;

Function
          tHelpObj.checkCtrlSelectionAndIndex( aInTemplIdx: intEger; Out aOutTemplIdx: intEger): boolEan;
Begin
          Result      := checkCtrlSelection();
          aOutTemplIdx:= 0;

          If Not Result
             Then
             Exit;

          If ( -1< aInTemplIdx)
             And
             ( pslCurSelCtrls.Count> aInTemplIdx)
             Then
             aOutTemplIdx:= aInTemplIdx;

          Result:= True;
End;

Procedure
          tHelpObj.alignRightOrBottom( aCtlDim: tCtrlDim; aTemplIdx: intEger= 0);
Var
          vInTIx                            : intEger;

          vInDiff                           : intEger;
          vIn1                              : intEger;
          vIn2                              : intEger;

          vtReCt                            : tRect;
          vtReCi                            : tRect;
Begin
          If Not checkCtrlSelectionAndIndex( aTemplIdx, vInTIx)
             Then
             Exit;

          Try
             vtReCt:= tControl( pslCurSelCtrls[ vInTIx]).BoundsRect;

             vIn2:= pslCurSelCtrls.Count;
             For vIn1:= 0 To vIn2- 1
                 Do
                 Begin
                      If ( vInTIx<> vIn1)
                         Then
                         Begin
                              vtReCi:= tControl( pslCurSelCtrls[ vIn1]).BoundsRect;

                              If aCtlDim= ctdRight
                                 Then
                                 vInDiff:= vtReCt.Right - vtReCi.Right    // might be negative
                              Else
                                 vInDiff:= vtReCt.Bottom- vtReCi.Bottom;  // might be negative

                              If ( 0<> vInDiff)
                                 Then
                                 Begin
                                      If aCtlDim= ctdRight
                                         Then
                                         Begin
                                              vtReCi.Right:= vtReCt.Right;
                                              vtReCi.Left := vtReCi.Left+ vInDiff;
                                         End
                                      Else
                                         Begin
                                              vtReCi.Bottom:= vtReCt.Bottom;
                                              vtReCi.Top   := vtReCi.Top+ vInDiff;
                                      End;
                                      tControl( pslCurSelCtrls[ vIn1]).SetBounds( vtReCi.Left, vtReCi.Top, vtReCi.Width, vtReCi.Height);
                              End;
                      End;
             End;
             tryRefreshLUR();

          Except End;
End;

Procedure
          tHelpObj.ctrlDimHlper( aCtrlIdx: intEger; aCtlDim: tCtrlDim; aSpec: tHgtWthMinOrMax; Var aVarResIdx: intEger; Var aVarMostVal: intEger);
Var
          vtReCi                            : tRect;
Begin
          Try
             vtReCi:= tControl( pslCurSelCtrls[ aCtrlIdx]).BoundsRect;
             Case aCtlDim Of
                  ctdRight :  If vtReCi.Right > aVarMostVal
                                 Then
                                 Begin
                                      aVarMostVal:= vtReCi.Right;
                                      aVarResIdx := aCtrlIdx;
                              End;
                  ctdBottom:  If vtReCi.Bottom> aVarMostVal
                                 Then
                                 Begin
                                      aVarMostVal:= vtReCi.Bottom;
                                      aVarResIdx := aCtrlIdx;
                              End;
                  ctdHeight:  If ( ( aSpec= hwMax) And ( vtReCi.Height> aVarMostVal))
                                 Or
                                 ( ( aSpec= hwMin) And ( vtReCi.Height< aVarMostVal))
                                 Then
                                 Begin
                                      aVarMostVal:= vtReCi.Height;
                                      aVarResIdx := aCtrlIdx;
                              End;
                  ctdWidth :  If ( ( aSpec= hwMax) And ( vtReCi.Width > aVarMostVal))
                                 Or
                                 ( ( aSpec= hwMin) And ( vtReCi.Width < aVarMostVal))
                                 Then
                                 Begin
                                      aVarMostVal:= vtReCi.Width;
                                      aVarResIdx := aCtrlIdx;
                              End;
             End;

          Except End;
End;

Function
          tHelpObj.getldxOfCtrlWthSpecDimValue( aCtlDim: tCtrlDim; aSpec: tHgtWthMinOrMax= hwNone): intEger;
Var
          vInMost                           : intEger;
          vIn1                              : intEger;
          vIn2                              : intEger;

Begin
          Result:= -1;
          If Not checkCtrlSelection()
             Then
             Exit;

          Try
             If aSpec= hwMax
                Then
                vInMost:= Low ( intEger)
             Else
                vInMost:= High( intEger);

             vIn2:= pslCurSelCtrls.Count;

             For vIn1:= 0 To vIn2- 1
                 Do
                 ctrlDimHlper( vIn1, aCtlDim, aSpec, Result, vInMost);

          Except End;

End;

Procedure
          tHelpObj.alignRightOrBottom( aSender: tObject; aCtlDim: tCtrlDim; aSpec: tHgtWthMinOrMax= hwNone); Overload;
Var
          vInTmplIdx                        : intEger;
Begin
          nOp( aSender);

          If ( hwNone<> aSpec)
             Then
             vInTmplIdx:= getldxOfCtrlWthSpecDimValue( aCtlDim, aSpec)
          Else
             vInTmplIdx:= 0;

          If ( -1< vInTmplIdx)
             Then
             alignRightOrBottom( aCtlDim, vInTmplIdx);

End;

Procedure
          tHelpObj.alignRight( aSender: tObject);
Begin
          alignRightOrBottom( aSender, ctdRight);
End;

Procedure
          tHelpObj.alignBottom( aSender: tObject);
Begin
          alignRightOrBottom( aSender, ctdBottom);
End;

Procedure
          tHelpObj.alignRightMost( aSender: tObject);
Begin
          alignRightOrBottom( aSender, ctdRight, hwMax);
End;

Procedure
          tHelpObj.alignBottomMost( aSender: tObject);
Begin
          alignRightOrBottom( aSender, ctdBottom, hwMax);
End;

Procedure
          tHelpObj.alignHeightOrWidth( aCtlDim: tCtrlDim; aTemplIdx: intEger= 0);
Var
          vInTIx                            : intEger;

          vIn1                              : intEger;
          vIn2                              : intEger;

          vtReCt                            : tRect;
          vtReCi                            : tRect;
Begin
          If Not checkCtrlSelectionAndIndex( aTemplIdx, vInTIx)
             Then
             Exit;

          Try
             vtReCt:= tControl( pslCurSelCtrls[ vInTIx]).BoundsRect;

             vIn2:= pslCurSelCtrls.Count;
             For vIn1:= 0 To vIn2- 1
                 Do
                 Begin
                      If ( vInTIx<> vIn1)
                         Then
                         Begin
                              vtReCi:= tControl( pslCurSelCtrls[ vIn1]).BoundsRect;

                              If ( ( aCtlDim= ctdHeight) And ( vtReCi.Height<> vtReCt.Height))
                                 Then
                                 Begin
                                      tControl( pslCurSelCtrls[ vIn1]).AutoSize:= False;
                                      vtReCi.Height := vtReCt.Height;
                              End;

                              If ( ( aCtlDim= ctdWidth ) And ( vtReCi.Width <> vtReCt.Width ))
                                 Then
                                 Begin
                                      tControl( pslCurSelCtrls[ vIn1]).AutoSize:= False;
                                      vtReCi.Width  := vtReCt.Width;

                              End;
                              tControl( pslCurSelCtrls[ vIn1]).SetBounds( vtReCi.Left, vtReCi.Top, vtReCi.Width, vtReCi.Height);
                      End;
             End;
             tryRefreshLUR();

          Except End;
End;


Procedure
          tHelpObj.alignHeight( aSender: tObject);
Begin
          nOp( aSender);
          alignHeightOrWidth( ctdHeight);
End;

Procedure
          tHelpObj.alignWidth( aSender: tObject);
Begin
          nOp( aSender);
          alignHeightOrWidth( ctdWidth);
End;

Procedure
          tHelpObj.alignXest( aSender: tObject; aCtlDim: tCtrlDim; aSpec: tHgtWthMinOrMax= hwNone);
Var
          vInTmplIdx                        : intEger;
Begin
          nOp( aSender);

          vInTmplIdx:= getldxOfCtrlWthSpecDimValue( aCtlDim, aSpec);

          If ( -1< vInTmplIdx)
             Then
             alignHeightOrWidth( aCtlDim, vInTmplIdx);
End;

Procedure
          tHelpObj.alignHighest( aSender: tObject);
Begin
          alignXest( aSender, ctdHeight, hwMax);
End;

Procedure
          tHelpObj.alignLowest( aSender: tObject);
Begin
          alignXest( aSender, ctdHeight, hwMin);
End;


Procedure
          tHelpObj.alignWidest( aSender: tObject);
Begin
          alignXest( aSender, ctdWidth, hwMax);
End;

Procedure
          tHelpObj.alignSmallest( aSender: tObject);
Begin
          alignXest( aSender, ctdWidth, hwMin);
End;


Constructor
          tHelpObj.create();
Begin
          pslCurSelComps:= Nil;
          pslCurSelCtrls:= Nil;
End;



Initialization
Begin
          ho_Obj:= tHelpObj.Create();


End;

Finalization
Begin
          If assigned( GlobalDesignHook)
             Then
             GlobalDesignHook.RemoveHandlerSetSelection( @ho_Obj.PropHookSetSelection);

End;

End.

