          { Copyright (C) 2025  StOver }
          {$CODEPAGE UTF8}
Unit
          alignComponentsImpl;

          {$mode objfpc}{$H+}
          {$ModeSwitch typehelpers}


Interface

//Uses
//          propedits
//          ,
//          Forms
//          ;
//
//Type
//          // helps to debug during runtime w/o much changing
//          tHelpObjExt                          = Class
//
//             Function                          prepPersList( aForm: tForm): tPersistentSelectionList;
//             Procedure                         alignLeft( aForm: tForm);
//             Procedure                         distrVerEvn( aForm: tForm);
//
//          End;

Procedure
          Register;

implementation

Uses
          Classes,
          SysUtils,
          Generics.Defaults,
          Generics.Collections,
          Controls,
          Forms,
          Dialogs,
          menuintf,
          IDECommands,
          ToolBarIntf,
          FormEditingIntf,
          propedits,
          componenteditors,
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

          // distribution
          // min 3 sel ctrls
          SDSTRB_HOR_EVN                    = 'distribute_horizontally_evenly';
          SDSTRB_VER_EVN                    = 'distribute_vertically_evenly';

          //// min 2 sel ctrls
          SDSTRB_HOR_MRE                    = 'distribute_horizontally_more';
          SDSTRB_HOR_LSS                    = 'distribute_horizontally_less';

          SDSTRB_VER_MRE                    = 'distribute_vertically_more';
          SDSTRB_VER_LSS                    = 'distribute_vertically_less';

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

          SDSTRB_HEV_IDEMenuCaption         = 'Horizontal gleichmäßig verteilen';
          SDSTRB_VEV_IDEMenuCaption         = 'Vertikal gleichmäßig verteilen';

          SDSTRB_HMR_IDEMenuCaption         = 'Horizontal mehr verteilen';
          SDSTRB_HLS_IDEMenuCaption         = 'Horizontal weniger verteilen';

          SDSTRB_VMR_IDEMenuCaption         = 'Vertikal mehr verteilen';
          SDSTRB_VLS_IDEMenuCaption         = 'Vertikal weniger verteilen';

Type
          tCompDim                          = ( cpdLeft , cpdTop   );

          tCtrlDim                          = ( ctdLeft , ctdRight , ctdTop  , ctdBottom, ctdHorCtr, ctdVerCtr, ctdHeight, ctdWidth);
          tCtrlDimArray                     = Array Of tCtrlDim;

          tDirection                        = ( dirHoriz, dirVertic);
          tRelativeComp                     = ( recoNone, recoMin  , recoMax, recoLess  , recoMore );

          tControlBounds                    = Record

             CtrlIdx                        : intEger;
             Bounds                         : tRect;

          End;
          tControlBoundArray                = Specialize tArray< tControlBounds>;


          { tHCtrlDimArray }

          tHCtrlDimArray                    = Type Helper For tCtrlDimArray

          Public

             Function                       cnt_get(): intEger;

             Property                       Count: intEger Read cnt_get;
          End;



          { tControlBoundsComparer }

          tControlBoundsComparer            = Class( Specialize tComparer< tControlBounds>)

          Private

             dimsWhich                       : tCtrlDimArray;

          Public

             Function                       compare1DHorCtr( aDim: tCtrlDim; ConstRef aLeft: tControlBounds; ConstRef aRght: tControlBounds; Out aOutCompRes: intEger): boolEan;
             Function                       compare1DVerCtr( aDim: tCtrlDim; ConstRef aLeft: tControlBounds; ConstRef aRght: tControlBounds; Out aOutCompRes: intEger): boolEan;

             Function                       compare1DLeft  ( aDim: tCtrlDim; ConstRef aLeft: tControlBounds; ConstRef aRght: tControlBounds; Out aOutCompRes: intEger): boolEan;
             Function                       compare1DRight ( aDim: tCtrlDim; ConstRef aLeft: tControlBounds; ConstRef aRght: tControlBounds; Out aOutCompRes: intEger): boolEan;

             Function                       compare1DTop   ( aDim: tCtrlDim; ConstRef aLeft: tControlBounds; ConstRef aRght: tControlBounds; Out aOutCompRes: intEger): boolEan;
             Function                       compare1DBottom( aDim: tCtrlDim; ConstRef aLeft: tControlBounds; ConstRef aRght: tControlBounds; Out aOutCompRes: intEger): boolEan;

             Function                       compareOneDim  ( aDim: tCtrlDim; ConstRef aLeft: tControlBounds; ConstRef aRght: tControlBounds): intEger;
             {$If ( FPC_VERSION> 2) And ( FPC_RELEASE> 2) And ( FPC_PATCH> 0)}
             Function                       compare( Const aLeft: tControlBounds; Const aRght: tControlBounds): intEger; Override;
             {$Else}
             Function                       compare( ConstRef aLeft: tControlBounds; ConstRef aRght: tControlBounds): intEger; Override;
             {$EndIf}

             constructor                    create();
             Constructor                    create( aCtrlDims: tCtrlDimArray);

          End;

          { tTypeHlprBase }

          Generic tTypeHlprBase< T>         = Class( tObject)
          Public
             Class Procedure                exChange( Var aVarLeftPrt: T; Var aVarRghtPrt: T);
          End;

          { tTypeHelperInt }

          tTypeHelperInt                    = Specialize tTypeHlprBase< intEger>;

          { tHTypeHelperInt }

          tHTypeHelperInt                   = Type Helper( tIntegerHelper) For intEger
             Procedure                      exChange( Var aVarCntrPrt: intEger);

          End;


          { tIntegerComparer }

          tIntegerComparer                  = Class( Specialize tComparer< Integer>)

          Public

             {$If ( FPC_VERSION> 2) And ( FPC_RELEASE> 2) And ( FPC_PATCH> 0)}
             Function                       compare( Const aLeft: intEger; Const aRght: intEger): intEger; Override;
             {$Else}
             Function                       compare( ConstRef aLeft: intEger; ConstRef aRght: intEger): intEger; Override;
             {$EndIf}

          End;

          { tDynIntArray }

          tDynIntArray                      = Array Of Integer;

          { tHIntArray }

          tHIntArray                        = Type Helper For tDynIntArray

          Public

             Function                       io_Get( aValue: intEger): intEger;
             Function                       dc_Get(): intEger;
             Function                       d_Get(): tDynIntArray;
             Function                       cnt_get(): intEger;

             Property                       IndexOf[ aValue: intEger]: intEger Read io_Get;
             Property                       DistinctCount: intEger Read dc_Get;
             Property                       Distinct: tDynIntArray Read d_Get;
             Property                       Count: intEger Read cnt_get;

             Procedure                      Sort();

          End;

          { tControlBoundsCBData }

          tControlBoundsCBData              = Class( tObject)

          Public
             ControlDim                     : tCtrlDim;

             Stop                           : boolEan;
             Parent                         : tControlBoundArray;
             ElementIdx                     : intEger;

             IntResult                      : intEger;

             Constructor                    create();
             Constructor                    create( aControlDim: tCtrlDim);

          End;

          tControlBoundsCallback            = Procedure ( Var aData: tControlBoundsCBData) Of Object;

          { tHControlBoundArray }

          tHControlBoundArray               = Type Helper For tControlBoundArray

          Private

          Public

             Procedure                      thinOut( aIdxsToExclude: tDynIntArray);
             Procedure                      sort( aCtrlDims: tCtrlDimArray);
             Procedure                      forEach( aCallBack: tControlBoundsCallback; Var aData: tControlBoundsCBData);
             Function                       cnt_get(): intEger;

             Property                       Count: intEger Read cnt_get;

          End;

          { tHRect }

          tHRect                            = Type Helper For tRect

          Private

          Public

             Function                       registerControlUndoActions( aControl: tControl; aOldBounds: tRect): boolEan;

             Procedure                      setControlBounds( aControl: tControl);

             Function                       setLeft( aNewLeft: intEger): intEger;
             Function                       setTop ( aNewTop : intEger): intEger;

             Function                       getDistance( aCntrPart: tRect; aCtrlDims: tCtrlDimArray): intEger;
             Function                       setDistance( aControl: tControl; aDistance: intEger; aCntrPart: tRect; aCtrlDims: tCtrlDimArray): intEger;

             Function                       toString(): String;

          End;

          { tHelpObj }

          tHelpObj                          = Class( tObject)

             pslCurSelComps                 : tPersistentSelectionList;
             pslCurSelCtrls                 : tPersistentSelectionList;

          Public

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

             Function                       getIdxOfCompWthSpecDimValue( aCompDim: tCompDim; aSpec: tRelativeComp): intEger;

             Function                       checkCtrlSelection( aMinCnt: intEger= 2): boolEan;
             Function                       checkCtrlSelectionAndIndex( aInTemplIdx: intEger; Out aOutTemplIdx: intEger): boolEan;

             Procedure                      alignLeftMost( aSender: tObject);
             Procedure                      alignTopMost( aSender: tObject);

             Procedure                      alignRightOrBottom( aCtlDim: tCtrlDim; aTemplIdx: intEger= 0); Overload;
             Procedure                      alignRightOrBottom( aSender: tObject; aCtlDim: tCtrlDim; aSpec: tRelativeComp); Overload;

             Procedure                      alignRight( aSender: tObject);
             Procedure                      alignBottom( aSender: tObject);

             Function                       ctrlDimHlperCheckOne( aCtrlIdx: intEger; aSpec: tRelativeComp; aCheckValue: intEGer; Var aVarResIdx: intEger; Var aVarMostVal: intEger): boolEan;
             Procedure                      ctrlDimHlper( aCtrlIdx: intEger; aCtlDim: tCtrlDim; aSpec: tRelativeComp; Var aVarResIdx: intEger; Var aVarMostVal: intEger);
             Function                       getIdxOfCtrlWthSpecDimValue( aCtlDim: tCtrlDim; aSpec: tRelativeComp= recoNone): intEger;

             Procedure                      alignRightMost( aSender: tObject);
             Procedure                      alignBottomMost( aSender: tObject);

             Procedure                      alignHeightOrWidth( aCtlDim: tCtrlDim; aTemplIdx: intEger= 0);

             Procedure                      alignHeight( aSender: tObject);
             Procedure                      alignWidth( aSender: tObject);

             Procedure                      alignXest( aSender: tObject; aCtlDim: tCtrlDim; aSpec: tRelativeComp= recoNone);

             Procedure                      alignHighest( aSender: tObject);
             Procedure                      alignLowest( aSender: tObject);

             Procedure                      alignWidest( aSender: tObject);
             Procedure                      alignSmallest( aSender: tObject);

             Function                       getCtrlBounds( aMinSelCnt: intEger): tControlBoundArray;

             Procedure                      ControlBoundsCallback( Var aData: tControlBoundsCBData);

             Procedure                      preventStalemateHoriz ( aCtrlBdAr: tControlBoundArray; Var aVarIdxFst: intEger; Var aVarIdxLst: intEger);
             Function                       distEvenCalcHoriz( aCtrlBdAr: tControlBoundArray; Out aOutIdxFst: intEger; Out aOutIdxLst: intEger; Out aOutStrtLimit: intEger; Out aOutLastLimit: intEger): tControlBoundsCBData;
             Procedure                      preventStalemateVertic( aCtrlBdAr: tControlBoundArray; Var aVarIdxFst: intEger; Var aVarIdxLst: intEger);
             Function                       distEvenCalcVertic( aCtrlBdAr: tControlBoundArray; Out aOutIdxFst: intEger; Out aOutIdxLst: intEger; Out aOutStrtLimit: intEger; Out aOutLastLimit: intEger): tControlBoundsCBData;

             Function                       distEvenCalc( aDirection: tDirection; Var aVarCtrlBdAr: tControlBoundArray; Out aOutStrtLimit: intEger; Out aOutDistance: intEger): boolEan;
             Procedure                      distributeEvenly( aDirection: tDirection);
             Procedure                      distrHorEvn( aSender: tObject);
             Procedure                      distrVerEvn( aSender: tObject);

             Function                       distrDSCorrectDistance( aDistance: intEger; aSpec: tRelativeComp): intEger;
             Procedure                      distrDimsSpec( aSender: tObject; aCtrlDims: tCtrlDimArray; aSpec: tRelativeComp);

             Procedure                      distrHorMore( aSender: tObject);
             Procedure                      distrHorLess( aSender: tObject);

             Procedure                      distrVerMore( aSender: tObject);
             Procedure                      distrVerLess( aSender: tObject);


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

          imcCmd_DSH_EVN                    : tIDEMenuCommand= Nil;   // distr hor ev
          imcCmd_DSV_EVN                    : tIDEMenuCommand= Nil;   // distr ver ev

          imcCmd_DSH_MRE                    : tIDEMenuCommand= Nil;   // distr hor more
          imcCmd_DSH_LSS                    : tIDEMenuCommand= Nil;   // distr hor less

          imcCmd_DSV_MRE                    : tIDEMenuCommand= Nil;   // distr ver more
          imcCmd_DSV_LSS                    : tIDEMenuCommand= Nil;   // distr ver less

          {%H-}ho_Obj: tHelpObj             = Nil;
          {%H+}

          {$hints off}
Procedure
          nOp( aSender : tObject);
Begin

End;

Function
          signalModified( aPstntt: tPersistent; Out aOutDesigner: tIDesigner): boolEan; Overload;
Begin
          Result:= False;
          aOutDesigner:= Nil;

          aOutDesigner:= findRootDesigner( aPstntt);
          If assigned( aOutDesigner)
             Then
             Begin
                  aOutDesigner.Modified;
                  Result:= True;
          End;
End;
Function
          signalModified( aPstntt: tPersistent): boolEan; Overload;
Var
          vtiDsgnr                          : tIDesigner;
Begin
          Result:= signalModified( aPstntt, vtiDsgnr);
End;

Function
          signalModAndAddUndoAction( aPstntt: tPersistent; aFieldName: String; Const aOldVal: Variant; Const aNewVal: Variant): boolEan;
Var
          viDesigner                        : tIDesigner;
          CompEditDsg                       : tComponentEditorDesigner;
Begin
          Result:= False;
          If Not signalModified( aPstntt, viDesigner)
             Then
             Exit;

          If ( viDesigner Is tComponentEditorDesigner)
             Then
             Begin
                  CompEditDsg:= tComponentEditorDesigner( viDesigner);
                  Result:= CompEditDsg.AddUndoAction( aPstntt, uopChange, True, aFieldName, aOldVal, aNewVal);
          End;
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

          // distribute
          imcCmd_DSH_EVN:= registerOneCmd( SDSTRB_HOR_EVN, SDSTRB_HEV_IDEMenuCaption    , @ho_Obj.distrHorEvn);
          imcCmd_DSV_EVN:= registerOneCmd( SDSTRB_VER_EVN, SDSTRB_VEV_IDEMenuCaption    , @ho_Obj.distrVerEvn);

          imcCmd_DSH_MRE:= registerOneCmd( SDSTRB_HOR_MRE, SDSTRB_HMR_IDEMenuCaption    , @ho_Obj.distrHorMore);
          imcCmd_DSH_LSS:= registerOneCmd( SDSTRB_HOR_LSS, SDSTRB_HLS_IDEMenuCaption    , @ho_Obj.distrHorLess);

          imcCmd_DSV_MRE:= registerOneCmd( SDSTRB_VER_MRE, SDSTRB_VMR_IDEMenuCaption    , @ho_Obj.distrVerMore);
          imcCmd_DSV_LSS:= registerOneCmd( SDSTRB_VER_LSS, SDSTRB_VLS_IDEMenuCaption    , @ho_Obj.distrVerLess);

          GlobalDesignHook.AddHandlerSetSelection( @ho_Obj.PropHookSetSelection);
          //GetPropertyEditorHook();
End;


          { tControlBoundsCallbackData }

Constructor
          tControlBoundsCBData.create();
Begin
          Inherited create();
          IntResult    := 0;
          ElementIdx   := -1;
          Stop         := False;
          Parent       := Nil;
          ControlDim   := ctdLeft;
End;

Constructor
          tControlBoundsCBData.create( aControlDim: tCtrlDim);
Begin
          create();
          ControlDim:= aControlDim;
End;

          { tHtControlBoundArray }

Procedure
          tHControlBoundArray.thinOut( aIdxsToExclude: tDynIntArray);
Var
          vtCbaTemp                         : tControlBoundArray;
          aoiDist                           : tDynIntArray;
          vIn1                              : intEger;
          vIn2                              : intEger;
Begin
          If ( Not assigned( Self))
             Or
             ( 0= length( Self))
             Then
             Exit;

          aoiDist:= aIdxsToExclude.Distinct;
          aoiDist.Sort();
          vtCbaTemp:= [];

          vIn2:= length( Self);

          For vIn1:= 0 To vIn2- 1
              Do
              If ( -1= aoiDist.IndexOf[ vin1])
                 Then
                 vtCbaTemp:= concat( vtCbaTemp, [ Self[ vin1]]);

          Self:= vtCbaTemp;

End;

Procedure
          tHControlBoundArray.sort( aCtrlDims: tCtrlDimArray);
Var
          Comparer                          : tControlBoundsComparer;
Begin
          Comparer:= tControlBoundsComparer.Create( aCtrlDims);
          Specialize tArrayHelper< tControlBounds>.sort( Self, Comparer);
          freeAndNil( Comparer);
End;

Function
          tHControlBoundArray.cnt_get(): intEger;
Begin
          Result:= -1;
          If Not assigned( Self)
             Then
             Exit;

          Result:= length( Self);
End;

          { tHCtrlDimArray }

Function
          tHCtrlDimArray.cnt_get(): intEger;
Begin
          Result:= -1;
          If Not assigned( Self)
             Then
             Exit;

          Result:= length( Self);
End;

Operator
          In ( aElement: tCtrlDim; aCtrlDimArr: tCtrlDimArray): boolEan;
Var
          vIn1                              : intEger;
          vIn2                              : intEger;
Begin
          Result:= False;

          If Not assigned( aCtrlDimArr)
             Then
             Exit;

          vIn2:= aCtrlDimArr.Count;

          For vIn1:= 0 To vIn2- 1
              Do
              Begin
                   If ( aCtrlDimArr[ vIn1]= aElement)
                      Then
                      Begin
                           Result:= True;
                           Exit;
                   End;
          End;
End;

          { tControlBoundsComparer }

Function
          tControlBoundsComparer.compare1DHorCtr( aDim: tCtrlDim; ConstRef aLeft: tControlBounds; ConstRef aRght: tControlBounds; Out aOutCompRes: intEger): boolEan;
Begin
          aOutCompRes:= 0;
          Result:= ( aDim= ctdHorCtr);

          If Result
             Then
             If aLeft.Bounds.CenterPoint.X< aRght.Bounds.CenterPoint.X
                Then
                aOutCompRes:= -1
             Else
                If aLeft.Bounds.CenterPoint.X> aRght.Bounds.CenterPoint.X
                   Then
                   aOutCompRes:= +1;

End;

Function
          tControlBoundsComparer.compare1DVerCtr( aDim: tCtrlDim; ConstRef aLeft: tControlBounds; ConstRef aRght: tControlBounds; Out aOutCompRes: intEger): boolEan;
Begin
          aOutCompRes:= 0;
          Result:= ( aDim= ctdVerCtr);

          If Result
             Then
             If aLeft.Bounds.CenterPoint.Y< aRght.Bounds.CenterPoint.Y
                Then
                aOutCompRes:= -1
             Else
                If aLeft.Bounds.CenterPoint.Y> aRght.Bounds.CenterPoint.Y
                   Then
                   aOutCompRes:= +1;

End;

Function
          tControlBoundsComparer.compare1DLeft( aDim: tCtrlDim; ConstRef aLeft: tControlBounds; ConstRef aRght: tControlBounds; Out aOutCompRes: intEger): boolEan;
Begin
          aOutCompRes:= 0;
          Result:= ( aDim= ctdLeft);

          If Result
             Then
             If aLeft.Bounds.Left< aRght.Bounds.Left
                Then
                aOutCompRes:= -1
             Else
                If aLeft.Bounds.Left> aRght.Bounds.Left
                   Then
                   aOutCompRes:= +1;

End;

Function
          tControlBoundsComparer.compare1DRight( aDim: tCtrlDim; ConstRef aLeft: tControlBounds; ConstRef aRght: tControlBounds; Out aOutCompRes: intEger): boolEan;
Begin
          aOutCompRes:= 0;
          Result:= ( aDim= ctdRight);

          If Result
             Then
             If aLeft.Bounds.Right< aRght.Bounds.Right
                Then
                aOutCompRes:= -1
             Else
                If aLeft.Bounds.Right> aRght.Bounds.Right
                   Then
                   aOutCompRes:= +1;

End;

Function
          tControlBoundsComparer.compare1DTop( aDim: tCtrlDim; ConstRef aLeft: tControlBounds; ConstRef aRght: tControlBounds; Out aOutCompRes: intEger): boolEan;
Begin
          aOutCompRes:= 0;
          Result:= ( aDim= ctdTop);

          If Result
             Then
             If aLeft.Bounds.Top< aRght.Bounds.Top
                Then
                aOutCompRes:= -1
             Else
                If aLeft.Bounds.Top> aRght.Bounds.Top
                   Then
                   aOutCompRes:= +1;
End;

Function
          tControlBoundsComparer.compare1DBottom( aDim: tCtrlDim; ConstRef aLeft: tControlBounds; ConstRef aRght: tControlBounds; Out aOutCompRes: intEger): boolEan;
Begin
          aOutCompRes:= 0;
          Result:= ( aDim= ctdBottom);

          If Result
             Then
             If aLeft.Bounds.Bottom< aRght.Bounds.Bottom
                Then
                aOutCompRes:= -1
             Else
                If aLeft.Bounds.Bottom> aRght.Bounds.Bottom
                   Then
                   aOutCompRes:= +1;
End;

Function
          tControlBoundsComparer.compareOneDim( aDim: tCtrlDim; ConstRef aLeft: tControlBounds; ConstRef aRght: tControlBounds): intEger;
Begin
          Result:= 0;

          If Not compare1DHorCtr( aDim, aLeft, aRght, Result)
             Then
             If Not compare1DVerCtr( aDim, aLeft, aRght, Result)
                Then
                If Not compare1DLeft( aDim, aLeft, aRght, Result)
                   Then
                   If Not compare1DRight( aDim, aLeft, aRght, Result)
                      Then
                      If Not compare1DTop( aDim, aLeft, aRght, Result)
                         Then
                         compare1DBottom( aDim, aLeft, aRght, Result);



End;

Function
          {$If ( FPC_VERSION> 2) And ( FPC_RELEASE> 2) And ( FPC_PATCH> 0)}
          tControlBoundsComparer.compare( Const aLeft: tControlBounds; Const aRght: tControlBounds): intEger;
          {$Else}
          tControlBoundsComparer.compare( ConstRef aLeft: tControlBounds; ConstRef aRght: tControlBounds): intEger;
          {$EndIf}
Var
          vIn1                              : intEger;
          vIn2                              : intEger;
Begin
          Result:= 0;

          vIn1:= 0;
          vIn2:= dimsWhich.Count;

          While ( Result= 0) And ( vIn1< vIn2)
                Do
                Begin
                     Result:= compareOneDim( dimsWhich[ vIn1], aLeft, aRght);
                     inc( vIn1, 1);
          End;
End;


constructor
          tControlBoundsComparer.create();
Begin
          inherited create();
          dimsWhich:= [ ctdHorCtr];
End;

constructor
          tControlBoundsComparer.create( aCtrlDims: tCtrlDimArray);
Begin
          create();
          dimsWhich:= aCtrlDims;
End;

          { tTypeHlprBase }

Class Procedure
          tTypeHlprBase.exChange( Var aVarLeftPrt: T; Var aVarRghtPrt: T);
Var
          vTemp                             : T;
Begin
          vTemp      := aVarLeftPrt;
          aVarLeftPrt:= aVarRghtPrt;
          aVarRghtPrt:= vTemp;
End;

          { tHTypeHelperInt }

Procedure
          tHTypeHelperInt.exChange( Var aVarCntrPrt: intEger);
Begin
          tTypeHelperInt.exChange( Self, aVarCntrPrt);
End;


          { tIntegerComparer }

Function
          {$If ( FPC_VERSION> 2) And ( FPC_RELEASE> 2) And ( FPC_PATCH> 0)}
          tIntegerComparer.compare( Const aLeft: intEger; Const aRght: intEger): intEger;
          {$Else}
          tIntegerComparer.compare( ConstRef aLeft: intEger; ConstRef aRght: intEger): intEger;
          {$EndIf}
Begin
          Result:= 0;
          If ( aLeft< aRght)
             Then
             Result:= -1
          Else
             If ( aLeft> aRght)
             Then
             Result:= +1

End;

          { tHIntArray }
Function
          tHIntArray.io_Get( aValue: intEger): intEger;
Var
          vIn1                              : intEger;
          vIn2                              : intEger;
Begin
          Result:= -1;
          If ( Not assigned( Self))
             Or
             ( 0= length( Self))
             Then
             Exit;

          vIn2:= Length( Self);
          For vIn1:= 0 To vIn2- 1
              Do
              If ( Self[ vIn1]= aValue)
                 Then
                 Begin
                      Result:= vIn1;
                      Exit;
          End;
End;

Function
          tHIntArray.d_Get(): tDynIntArray;
Var
          vIn1                              : intEger;
          vIn2                              : intEger;
Begin
          Result:= [];
          If ( Not assigned( Self))
             Or
             ( 0= length( Self))
             Then
             Exit;

          vIn2:= length( Self);
          For vIn1:= 0 To vIn2- 1
              Do
              If ( -1= Result.IndexOf[ Self[ vIn1]])
                 Then
                 Result:= conCat( Result, [ Self[ vIn1]]);

End;

Function
          tHIntArray.dc_Get(): intEger;
Begin
          Result:= length( Self.Distinct);
End;

Procedure
          tHIntArray.Sort();
Var
          Comparer                          : tIntegerComparer;
Begin
          Comparer:= tIntegerComparer.Create();
          Specialize tArrayHelper< intEger>.Sort( Self, Comparer);
          freeAndNil( Comparer);
End;


Function
          tHIntArray.cnt_get(): intEger;
Begin
          Result:= -1;
          If Not assigned( Self)
             Then
             Exit;

          Result:= length( Self);
End;


Procedure
          tHControlBoundArray.forEach( aCallBack: tControlBoundsCallback; Var aData: tControlBoundsCBData);
Var
          vIn1                              : intEger;
          vIn2                              : intEger;
Begin
          If ( Not assigned( Self))
             Or
             ( Not assigned( aCallBack))
             Then
             Exit;

          If assigned( aData)
             Then
             aData.Parent:= Self;

          vIn2:= length( Self);
          For vIn1:= 0 To vIn2- 1
              Do
              Begin
                  If assigned( aData)
                     Then
                     aData.ElementIdx:= vIn1;

                  aCallBack( aData);

                  If assigned( aData)
                     And
                     aData.Stop
                     Then
                     Exit;
          End;
End;

          { tHRect }


Function
          tHRect.registerControlUndoActions( aControl: tControl; aOldBounds: tRect): boolEan;
Var
          vtReOld                           : tRect;
          vtReNew                           : tRect;
Begin
          Result:= False;
          If Not assigned( aControl)
             Then
             Exit;

          vtReOld:= aOldBounds;
          vtReNew:= aControl.BoundsRect;
          {$notes off}
          If ( vtReOld.Left  <> vtReNew.Left  )
             Then
             signalModAndAddUndoAction( aControl, 'Left'  , vtReOld.Left  , vtReNew.Left  );

          If ( vtReOld.Top   <> vtReNew.Top   )
             Then
             signalModAndAddUndoAction( aControl, 'Top'   , vtReOld.Top   , vtReNew.Top   );

          If ( vtReOld.Height<> vtReNew.Height)
             Then
             signalModAndAddUndoAction( aControl, 'Height', vtReOld.Height, vtReNew.Height);

          If ( vtReOld.Width <> vtReNew.Width )
             Then
             signalModAndAddUndoAction( aControl, 'Width' , vtReOld.Width , vtReNew.Width );

          {$notes on}
End;

Procedure
          tHRect.setControlBounds( aControl: tControl);
Var
          vtReOld                           : tRect;
Begin
          If Not assigned( aControl)
             Then
             Exit;

          vtReOld:= aControl.BoundsRect;
          aControl.SetBounds( Self.Left, Self.Top, Self.Width, Self.Height);
          registerControlUndoActions( aControl, vtReOld);

End;

Function  // sets left, returns right
          tHRect.setLeft( aNewLeft: intEger): intEger;
Var
          vInOldDim                         : intEger;
Begin
          vInOldDim := Self.Width;
          Self.Left := aNewLeft;
          Self.Right:= ( Self.Left+ vInOldDim);

          Result:= Self.Right;
End;

Function  // sets top, returns bottom
          tHRect.setTop ( aNewTop: intEger): intEger;
Var
          vInOldDim                         : intEger;
Begin
          vInOldDim  := Self.Height;
          Self.Top   := aNewTop;
          Self.Bottom:= ( Self.Top+ vInOldDim);

          Result:= Self.Bottom;
End;

Function
          tHRect.getDistance( aCntrPart: tRect; aCtrlDims: tCtrlDimArray): intEger;
Begin
          If ( ctdLeft In aCtrlDims)
             Then
             Result:= Self.Left- aCntrPart.Right;

          If ( ctdTop  In aCtrlDims)
             Then
             Result:= Self.Top - aCntrPart.Bottom;

End;

Function
          tHRect.setDistance( aControl: tControl; aDistance: intEger; aCntrPart: tRect; aCtrlDims: tCtrlDimArray): intEger;
Begin
          If ( ctdLeft In aCtrlDims)
             Then
             Begin
                  Result:= aCntrPart.Right+ aDistance;
                  Self.setLeft( Result);
             End
          Else
             Begin
                  Result:= aCntrPart.Bottom+ aDistance;
                  Self.setTop( Result);
          End;

          setControlBounds( aControl);
End;

Function
          tHRect.toString(): String;
Begin
          Result:= 'Left= %d, Top= %d, Width= %d, Height= %d';
          Result:= format( Result, [ Self.Left, Self.Top, Self.Width, Self.Height]);
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
                         imcCmd_SZE_HST, imcCmd_SZE_LST, imcCmd_SZE_WST, imcCmd_SZE_SST,
                         imcCmd_DSH_EVN, imcCmd_DSV_EVN,
                         imcCmd_DSH_MRE, imcCmd_DSH_LSS, imcCmd_DSV_MRE, imcCmd_DSV_LSS
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
                                         imcCmd_SZE_HST, imcCmd_SZE_LST, imcCmd_SZE_WST, imcCmd_SZE_SST,
                                         imcCmd_DSH_MRE, imcCmd_DSH_LSS, imcCmd_DSV_MRE, imcCmd_DSV_LSS
                                        ],
                                        True
                          );
                          If ( aCtrlSel> 2)
                             Then
                             xAbleCommands( [ imcCmd_DSH_EVN, imcCmd_DSV_EVN], True);
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
          tHelpObj.getIdxOfCompWthSpecDimValue( aCompDim: tCompDim; aSpec: tRelativeComp): intEger;
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
             If aSpec= recoMax
                Then
                vInMost:= Low ( intEger)
             Else
                vInMost:= High( intEger);

             vIn2:= pslCurSelComps.Count;

             For vIn1:= 0 To vIn2- 1
                 Do
                 Begin
                      GetComponentLeftTopOrDesignInfo( tComponent( pslCurSelComps[ vIn1]), vInLftC, vInTopC);

                      If ( ( aCompDim= cpdLeft) And ( aSpec= recoMin) And ( vInLftC< vInMost))
                         Or
                         ( ( aCompDim= cpdLeft) And ( aSpec= recoMax) And ( vInLftC> vInMost))
                         Then
                         Begin
                              vInMost:= vInLftC;
                              Result:= vIn1;
                      End;

                      If ( ( aCompDim= cpdTop ) And ( aSpec= recoMin) And ( vInTopC< vInMost))
                         Or
                         ( ( aCompDim= cpdTop ) And ( aSpec= recoMax) And ( vInTopC> vInMost))
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
                              If ( aCompDim= cpdLeft) And ( vInLftC<> vInLft)
                                 Then
                                 Begin
                                      SetComponentLeftTopOrDesignInfo( tComponent( pslCurSelComps[ vIn1]), vInLft, vInTopC);
                                      {$notes off}
                                      If ( pslCurSelComps[ vIn1] Is tControl)
                                         Then
                                         signalModAndAddUndoAction( pslCurSelComps[ vIn1], 'Left', vInLftC, vInLft)
                                      Else
                                         signalModified( pslCurSelComps[ vIn1])
                                      {$notes on}

                                 End
                              Else
                                 If ( aCompDim= cpdTop) And ( vInTopC<> vInTop)
                                    Then
                                    Begin
                                         SetComponentLeftTopOrDesignInfo( tComponent( pslCurSelComps[ vIn1]), vInLftC, vInTop);
                                         {$notes off}
                                         If ( pslCurSelComps[ vIn1] Is tControl)
                                            Then
                                            signalModAndAddUndoAction( pslCurSelComps[ vIn1], 'Top' , vInTopC, vInTop )
                                         Else
                                            signalModified( pslCurSelComps[ vIn1])
                                         {$notes on}
                                 End;
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
          vInTmplIdx:= getIdxOfCompWthSpecDimValue( cpdLeft, recoMin);

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

          vInTmplIdx:= getIdxOfCompWthSpecDimValue( cpdTop, recoMin);

          If ( -1< vInTmplIdx)
             Then
             alignTopOrLeft( cpdTop, vInTmplIdx);
End;

Function
          tHelpObj.checkCtrlSelection( aMinCnt: intEger= 2): boolEan;
Begin
          Result      := False;

          If Not assigned( pslCurSelCtrls)
             Then
             Exit;

          If ( pslCurSelCtrls.Count< aMinCnt)
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
                                      vtReCi.setControlBounds( tControl( pslCurSelCtrls[ vIn1]));
                              End;
                      End;
             End;
             tryRefreshLUR();

          Except End;
End;

Function
          tHelpObj.ctrlDimHlperCheckOne( aCtrlIdx: intEger; aSpec: tRelativeComp; aCheckValue: intEger; Var aVarResIdx: intEger; Var aVarMostVal: intEger): boolEan;
Begin
          Result:= False;
          Try
             If ( ( aSpec= recoMax) And ( aCheckValue  > aVarMostVal))
                Or
                ( ( aSpec= recoMin) And ( aCheckValue  < aVarMostVal))
                Then
                Begin
                     aVarMostVal:= aCheckValue;
                     aVarResIdx := aCtrlIdx;
                     Result     := True;
             End;

          Except End;
End;

Procedure
          tHelpObj.ctrlDimHlper( aCtrlIdx: intEger; aCtlDim: tCtrlDim; aSpec: tRelativeComp; Var aVarResIdx: intEger; Var aVarMostVal: intEger);
Var
          vtReCi                            : tRect;
Begin
          Try
             vtReCi:= tControl( pslCurSelCtrls[ aCtrlIdx]).BoundsRect;
             Case aCtlDim Of
                  ctdLeft  : ctrlDimHlperCheckOne( aCtrlIdx, aSpec, vtReCi.Left          , aVarResIdx, aVarMostVal);
                  ctdRight : ctrlDimHlperCheckOne( aCtrlIdx, aSpec, vtReCi.Right         , aVarResIdx, aVarMostVal);
                  ctdTop   : ctrlDimHlperCheckOne( aCtrlIdx, aSpec, vtReCi.Top           , aVarResIdx, aVarMostVal);
                  ctdBottom: ctrlDimHlperCheckOne( aCtrlIdx, aSpec, vtReCi.Bottom        , aVarResIdx, aVarMostVal);

                  ctdHorCtr: ctrlDimHlperCheckOne( aCtrlIdx, aSpec, vtReCi.CenterPoint.X , aVarResIdx, aVarMostVal);
                  ctdVerCtr: ctrlDimHlperCheckOne( aCtrlIdx, aSpec, vtReCi.CenterPoint.Y , aVarResIdx, aVarMostVal);

                  ctdHeight: ctrlDimHlperCheckOne( aCtrlIdx, aSpec, vtReCi.Height        , aVarResIdx, aVarMostVal);
                  ctdWidth : ctrlDimHlperCheckOne( aCtrlIdx, aSpec, vtReCi.Width         , aVarResIdx, aVarMostVal);
             End;

          Except End;
End;

Function
          tHelpObj.getIdxOfCtrlWthSpecDimValue( aCtlDim: tCtrlDim; aSpec: tRelativeComp= recoNone): intEger;
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
             If aSpec= recoMax
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
          tHelpObj.alignRightOrBottom( aSender: tObject; aCtlDim: tCtrlDim; aSpec: tRelativeComp); Overload;
Var
          vInTmplIdx                        : intEger;
Begin
          nOp( aSender);

          If ( recoNone<> aSpec)
             Then
             vInTmplIdx:= getIdxOfCtrlWthSpecDimValue( aCtlDim, aSpec)
          Else
             vInTmplIdx:= 0;

          If ( -1< vInTmplIdx)
             Then
             alignRightOrBottom( aCtlDim, vInTmplIdx);

End;

Procedure
          tHelpObj.alignRight( aSender: tObject);
Begin
          alignRightOrBottom( aSender, ctdRight, recoNone);
End;

Procedure
          tHelpObj.alignBottom( aSender: tObject);
Begin
          alignRightOrBottom( aSender, ctdBottom, recoNone);
End;

Procedure
          tHelpObj.alignRightMost( aSender: tObject);
Begin
          alignRightOrBottom( aSender, ctdRight, recoMax);
End;

Procedure
          tHelpObj.alignBottomMost( aSender: tObject);
Begin
          alignRightOrBottom( aSender, ctdBottom, recoMax);
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
                              vtReCi.setControlBounds( tControl( pslCurSelCtrls[ vIn1]));
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
          tHelpObj.alignXest( aSender: tObject; aCtlDim: tCtrlDim; aSpec: tRelativeComp= recoNone);
Var
          vInTmplIdx                        : intEger;
Begin
          nOp( aSender);

          vInTmplIdx:= getIdxOfCtrlWthSpecDimValue( aCtlDim, aSpec);

          If ( -1< vInTmplIdx)
             Then
             alignHeightOrWidth( aCtlDim, vInTmplIdx);
End;

Procedure
          tHelpObj.alignHighest( aSender: tObject);
Begin
          alignXest( aSender, ctdHeight, recoMax);
End;

Procedure
          tHelpObj.alignLowest( aSender: tObject);
Begin
          alignXest( aSender, ctdHeight, recoMin);
End;


Procedure
          tHelpObj.alignWidest( aSender: tObject);
Begin
          alignXest( aSender, ctdWidth, recoMax);
End;

Procedure
          tHelpObj.alignSmallest( aSender: tObject);
Begin
          alignXest( aSender, ctdWidth, recoMin);
End;

Function
          tHelpObj.getCtrlBounds( aMinSelCnt: intEger): tControlBoundArray;
Var
          vIn1                              : intEger;
          vIn2                              : intEger;
          vResidx                           : intEger;
          vtRe1                             : tRect;
          vtCBds1                           : tControlBounds;
Begin
          Result:= [];
          If Not checkCtrlSelection( aMinSelCnt)
             Then
             Exit;

          vIn2:= pslCurSelCtrls.Count;
          setLength( Result, vIn2);
          vResidx:= 0;

          For vIn1:= 0 To vIn2- 1
              Do
              Begin
                      vtRe1:= tControl( pslCurSelCtrls[ vIn1]).BoundsRect;
                      vtCBds1.CtrlIdx := vIn1;
                      vtCBds1.Bounds  := vtRe1;
                      Result[ vResidx]:= vtCBds1;
                      inc( vResidx, 1);
          End;

End;

Procedure
          tHelpObj.ControlBoundsCallback( Var aData: tControlBoundsCBData);
Begin
          If ( Not assigned( aData))
             Or
             ( Not assigned( aData.Parent))
             Or
             ( Not assigned( pslCurSelCtrls))
             Then
             Exit;

          If aData.ControlDim= ctdWidth
             Then
             aData.IntResult+= aData.Parent[ aData.ElementIdx].Bounds.Width;

          If aData.ControlDim= ctdHeight
             Then
             aData.IntResult+= aData.Parent[ aData.ElementIdx].Bounds.Height;

End;


Procedure
          tHelpObj.preventStalemateHoriz( aCtrlBdAr: tControlBoundArray; Var aVarIdxFst: intEger; Var aVarIdxLst: intEger);
Begin
          If ( aVarIdxFst= aVarIdxLst)
             Then
             Exit;

          If     ( aCtrlBdAr[ aVarIdxFst].Bounds.Right= aCtrlBdAr[ aVarIdxLst].Bounds.Right)
             Then
             aVarIdxLst:= aVarIdxFst
          Else
             If ( aCtrlBdAr[ aVarIdxLst].Bounds.Left  = aCtrlBdAr[ aVarIdxFst].Bounds.Left )
                Then
                aVarIdxFst:= aVarIdxLst;

End;

Function
          tHelpObj.distEvenCalcHoriz( aCtrlBdAr: tControlBoundArray; Out aOutIdxFst: intEger; Out aOutIdxLst: intEger; Out aOutStrtLimit: intEger; Out aOutLastLimit: intEger): tControlBoundsCBData;
Begin
          aOutIdxFst   := getIdxOfCtrlWthSpecDimValue( ctdLeft  , recoMin);  // right  x of the control that has left   most
          aOutIdxLst   := getIdxOfCtrlWthSpecDimValue( ctdRight , recoMax);  // left   x of the control that has right  most

          preventStalemateHoriz( aCtrlBdAr, aOutIdxFst, aOutIdxLst);

          aOutStrtLimit:= aCtrlBdAr[ aOutIdxFst].Bounds.Right;
          aOutLastLimit:= aCtrlBdAr[ aOutIdxLst].Bounds.Left;

          Result       := tControlBoundsCBData.create( ctdWidth);

End;

Procedure
          tHelpObj.preventStalemateVertic( aCtrlBdAr: tControlBoundArray; Var aVarIdxFst: intEger; Var aVarIdxLst: intEger);
Begin
          If ( aVarIdxFst= aVarIdxLst)
             Then
             Exit;

          If    ( aCtrlBdAr[ aVarIdxFst].Bounds.Bottom= aCtrlBdAr[ aVarIdxLst].Bounds.Bottom)
             Then
             aVarIdxLst:= aVarIdxFst
          Else
             If ( aCtrlBdAr[ aVarIdxLst].Bounds.Top   = aCtrlBdAr[ aVarIdxFst].Bounds.Top   )
                Then
                aVarIdxFst:= aVarIdxLst;

End;

Function
          tHelpObj.distEvenCalcVertic( aCtrlBdAr: tControlBoundArray; Out aOutIdxFst: intEger; Out aOutIdxLst: intEger; Out aOutStrtLimit: intEger; Out aOutLastLimit: intEger): tControlBoundsCBData;
Begin
          aOutIdxFst   := getIdxOfCtrlWthSpecDimValue( ctdTop   , recoMin);  // bottom y of the control that has top    most
          aOutIdxLst   := getIdxOfCtrlWthSpecDimValue( ctdBottom, recoMax);  // top    y of the control that has bottom most

          preventStalemateVertic( aCtrlBdAr, aOutIdxFst, aOutIdxLst);

          aOutStrtLimit:= aCtrlBdAr[ aOutIdxFst].Bounds.Bottom;
          aOutLastLimit:= aCtrlBdAr[ aOutIdxLst].Bounds.Top;

          Result       := tControlBoundsCBData.create( ctdHeight);

End;


Function
          tHelpObj.distEvenCalc( aDirection: tDirection; Var aVarCtrlBdAr: tControlBoundArray; Out aOutStrtLimit: intEger; Out aOutDistance: intEger): boolEan;
Var
          vInIdxFrst                        : intEger;
          vInIdxLast                        : intEger;

          vtCbCbDta                         : tControlBoundsCBData;

          vInLstLimit                       : intEger;

          vInCntCtls                        : intEger;

          vInAvlSpce                        : intEger;           // available space to distribute
          vInCtlsDim                        : intEger;           // sum of all heights/widths
          vInAvlRest                        : intEger;           // remaining space (might be negative)

          vtCtDmSort                        : tCtrlDim;
Begin
          Result:= False;

          aOutStrtLimit:= 0;
          aOutDistance:= 0;
          If Not checkCtrlSelection( 3)
             Then
             Exit;

          Try
             If aDirection= dirHoriz
                Then
                vtCbCbDta    := distEvenCalcHoriz ( aVarCtrlBdAr, vInIdxFrst, vInIdxLast, aOutStrtLimit, vInLstLimit)
             Else
                vtCbCbDta    := distEvenCalcVertic( aVarCtrlBdAr, vInIdxFrst, vInIdxLast, aOutStrtLimit, vInLstLimit);

             If vInIdxLast= vInIdxFrst
                Then
                aOutStrtLimit.exChange( vInLstLimit);

             vInAvlSpce:= vInLstLimit- aOutStrtLimit;

             aVarCtrlBdAr.thinOut( [ vInIdxFrst, vInIdxLast]);

             aVarCtrlBdAr.forEach( @ControlBoundsCallback, vtCbCbDta);
             vInCtlsDim:= vtCbCbDta.IntResult;
             freeAndNil( vtCbCbDta);

             vInAvlRest:= vInAvlSpce- vInCtlsDim;

             vInCntCtls:= aVarCtrlBdAr.Count;

             aOutDistance:= vInAvlRest Div ( vInCntCtls+ 1);

             vtCtDmSort:= ctdVerCtr;
             If aDirection= dirHoriz
                Then
                vtCtDmSort:= ctdHorCtr;
             aVarCtrlBdAr.Sort( [ vtCtDmSort]);
             Result:= ( vInCntCtls> 0);

          Except End;
End;

Procedure
          tHelpObj.distributeEvenly( aDirection: tDirection);
Var
          vtCtlBds                          : tControlBoundArray;

          vInCurLimit                       : intEger;
          vInCntCtls                        : intEger;

          vInCtlDstc                        : intEger;
          vIn1                              : intEger;
          vInNewStrt                        : intEger;
          vtRe1                             : tRect;
Begin
          vtCtlBds:= getCtrlBounds( 3);
          If Not distEvenCalc( aDirection, vtCtlBds, vInCurLimit, vInCtlDstc)
             Then
             Exit;

          Try
             vInCntCtls:= vtCtlBds.Count;

             For vIn1:= 0 To vInCntCtls- 1
                 Do
                 Begin
                      vInNewStrt:= vInCurLimit+ vInCtlDstc;
                      vtRe1:= vtCtlBds[ vIn1].Bounds;

                     If aDirection= dirHoriz
                        Then
                        vInCurLimit:= vtRe1.setLeft( vInNewStrt)
                     Else
                        vInCurLimit:= vtRe1.setTop ( vInNewStrt);

                     vtRe1.setControlBounds( tControl( pslCurSelCtrls[ vtCtlBds[ vIn1].CtrlIdx]));
             End;

          Except End;

          tryRefreshLUR();

End;

Procedure
          tHelpObj.distrHorEvn( aSender: tObject);
Begin
          nOp( aSender);
          distributeEvenly( dirHoriz);
End;

Procedure
          tHelpObj.distrVerEvn( aSender: tObject);
Begin
          nOp( aSender);
          distributeEvenly( dirVertic);
End;

Function
          tHelpObj.distrDSCorrectDistance( aDistance: intEger; aSpec: tRelativeComp): intEger;
Begin
          If ( recoMore= aSpec)
             Then
             Begin
                  If ( aDistance< 1)
                     Then
                     Result:= 1
                  Else
                     Result:= aDistance* 2;
             End
          Else
             Begin
                  If ( aDistance< 4)
                     Then
                     Result:= 0
                  Else
                     Result:= aDistance Div 2;
          End;
End;

Procedure
          tHelpObj.distrDimsSpec( aSender: tObject; aCtrlDims: tCtrlDimArray; aSpec: tRelativeComp);
Var
          vtCtlBds                          : tControlBoundArray;

          vInOrgDist                        : intEger;
          vInNewDist                        : intEger;

          vIn1                              : intEger;
          vInCntCtls                        : intEger;

          vtReLstBef                        : tRect;
          vtReCurBef                        : tRect;
          vtReLstAct                        : tRect;

          vtLstCtrl                         : tControl;
          vtCurCtrl                         : tControl;
Begin
          nOp( aSender);
          vtCtlBds:= getCtrlBounds( 2);
          vInCntCtls:= vtCtlBds.Count;
          If ( 2> vInCntCtls)
             Or
             ( 2> aCtrlDims.Count)
             Then
             Exit;

          vtCtlBds.Sort( aCtrlDims);

          Try

             For vIn1:= 1 To vInCntCtls- 1
                 Do
                 Begin
                      vtReCurBef := vtCtlBds[ vIn1].Bounds;
                      vtReLstBef := vtCtlBds[ vIn1- 1].Bounds;

                      vInOrgDist := vtReCurBef.getDistance( vtReLstBef, aCtrlDims);
                      vInNewDist := distrDSCorrectDistance( vInOrgDist, aSpec);

                      vtLstCtrl  := tControl( pslCurSelCtrls[ vtCtlBds[ vIn1- 1].CtrlIdx]);
                      vtReLstAct := vtLstCtrl.BoundsRect;

                      vtCurCtrl  := tControl( pslCurSelCtrls[ vtCtlBds[ vIn1].CtrlIdx]);
                      vtReCurBef .setDistance( vtCurCtrl, vInNewDist, vtReLstAct, aCtrlDims);
             End;

          Except End;
End;


Procedure
          tHelpObj.distrHorMore( aSender: tObject);
Begin
          distrDimsSpec( aSender, [ ctdLeft, ctdRight], recoMore);
End;

Procedure
          tHelpObj.distrHorLess( aSender: tObject);
Begin
          distrDimsSpec( aSender, [ ctdLeft, ctdRight], recoLess);
End;

Procedure
          tHelpObj.distrVerMore( aSender: tObject);
Begin
          distrDimsSpec( aSender, [ ctdTop, ctdBottom], recoMore);
End;

Procedure
          tHelpObj.distrVerLess( aSender: tObject);
Begin
          distrDimsSpec( aSender, [ ctdTop, ctdBottom], recoLess);
End;


Constructor
          tHelpObj.create();
Begin
          pslCurSelComps:= Nil;
          pslCurSelCtrls:= Nil;
End;

//          { tHelpObjExt }
//
//Function
//          tHelpObjExt.prepPersList( aForm: tForm): tPersistentSelectionList;
//Var
//          vIn1                              : intEger;
//          vIn2                              : intEger;
//Begin
//          Result:= tPersistentSelectionList.create();
//          vIn2:= aForm.ControlCount;
//
//          For vIn1:= 0 To vIn2- 1
//              Do
//              Result.Add( aForm.Controls[ vIn1]);
//
//End;
//
//Procedure
//          tHelpObjExt.alignLeft( aForm: tForm);
//Var
//          vtHo1                             : tHelpObj;
//          vtPsL1                            : tPersistentSelectionList;
//Begin
//          vtHo1:= tHelpObj.create();
//
//          vtPsl1:= prepPersList( aForm);
//
//          vtHo1.PropHookSetSelection( vtPsl1);
//          vtHo1.alignLeft( Self);
//
//          freeAndNil( vtHo1);
//End;
//
//Procedure
//          tHelpObjExt.distrVerEvn( aForm: tForm);
//Var
//          vtHo1                             : tHelpObj;
//          vtPsL1                            : tPersistentSelectionList;
//Begin
//          vtHo1:= tHelpObj.create();
//
//          vtPsl1:= prepPersList( aForm);
//
//          vtHo1.PropHookSetSelection( vtPsl1);
//          vtHo1.distrVerEvn( Self);
//
//          freeAndNil( vtHo1);
//End;

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

