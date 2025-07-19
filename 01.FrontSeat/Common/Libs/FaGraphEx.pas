(*
	만약 AxisScale이 asAngle이면 다음의 입력 규칙을 따라야 한다.
	규칙 : 도.나머지
	이유 : 내부적으로 도는 그냥 출력하고 분초는 나머지를 60 으로 나누어 계산하기 때문에
		   이를 틀리게 입력하면 화면에는 다르게 나타난다.


    기본 Data Type를 Double -> Currency로 변경
    ==========================================
    이유는 Double형일때 0 이 0.00000000000000000001 이런씩으로 나타남. 이런연유로 Currency로 변경함

        Type	    Range	                                        Significant digits	Size in bytes
        =========== =============================================== ==================  ==============
        Double	    5.0 x 10-324..1.7 x 10+308	                    15-16	            8
        Currency	-922337203685477.5808..922337203685477.5807	    19-20	            8
        
//======
// 수정사항
//===        
  Ver 1.0.0.5 2006.07.24
    1. Axix의 Label출력에 포맷형식 적용
      property LabelFormat : String read FLabelFormat write SetFormat nodefault ;

      o Length(FLabelFormat) = 0 이면 기존과 동일
      o Format의 종류는 두종류이다.
        TFaAxisScale이 DatetTime(FormatDateTime())계열인 경우는 yyyy"년"mm"월"nn"일"과 같이 표기하고
        asLog, asAngle는 바귄것이 없고
        asNormal, asDegree(FormatFloat())인 경우는 0.00과 같이 적용한다.
        
    2. asNormal에만 적용한 DrawMin, DrawMax를 전 Scale에 적용함.
*)

unit FaGraphEx;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, TimeCount,
  Extctrls;

const
	TFaGraphVersion = 'Ver 1.0.0.5' ;
type
	TFaAxisAlign = (aaLeft, aaRight, aaVertCenter, aaTop, aaBottom, aaHoriCenter) ;
	TFaAxisScale = (asNormal, asLog, asDate, asTime, asDegree, asAngle, asDateTime, asTimeHM, asDateMD) ;

	TFaGraphSide = (gsSide_1, gsSide_2, gsSide_3, gsSide_4) ;
	TFaGraphSides = set of TFaGraphSide ;

	TFaGraphGrid = (ggVert, ggHori) ;
	TFaGraphGrids = set of TFaGraphGrid ;

	TFaGraphStyle = (gsNone, gsLine, gsDot) ;
	TFaGraphPoint = (gpNone, gpCircle, gpCross, gpDiamond, gpRect, gpTUp, gpTDown, gpTLeft, gpTRight, gpX) ; //
	TGraphType = (gtNormal, gtScroll, gtStepScroll, gtAutoScroll, gtView) ;
	TFaGraphView = (gvNext, gvPrev, gvNextStep, gvPrevStep, gvNextPage, gvPrevPage, gvFirst, gvLast) ;
	TFaGraphSaveMode = (smNew, smAdd, smCur) ;
	TFaGraphLoadMode = (lmBegin, lmCur, lmSkip) ;

	TAxisData = ^Double ;
//	TAxisData = ^Currency ;

	TFaAxisRect = record
		Left	: Integer;
		Top		: Integer;
		Length	: Integer ;
		Width   : Integer ;
	end;

	TFaGraphEx = class ;
	TFaAxis = class ;
	TFaSeries = class ;

	TShareIndex = 0..255 ;
	TFaShareData = class
	private
		FMaxDatas  : Integer ;

		FGraphType : TGraphType ;
		FDatas     : array [0..255] of TList ;
	public
		constructor Create ;
		destructor  Destroy; override;
		procedure SetValue(iMax : Integer; gtType : TGraphType) ;
		procedure AddData(ShareIndex: Integer; Value : Double) ;
		procedure SetData(ShareIndex: Integer; Index : Integer; Value : Double) ;
		function  GetData(ShareIndex: Integer; Index : Integer; var Value : Double) : Boolean;
		procedure Empty(ShareIndex: Integer) ;
		function  GetMaxIndex(ShareIndex: Integer) : Integer ;

		function  CopyTo(ShareIndex: Integer; var Value : Array of Single; Count: Integer = 0) : Integer ;
		function  CopyFrom(ShareIndex: Integer; var Value : Array of Single; Count : Integer = 0) : Integer ;

		procedure Move(ShareIndex, CurIndex, NewIndex: Integer);
		procedure Delete(ShareIndex, Index: Integer);

        procedure Filter(iShareIndex : Integer) ;
		procedure FilterRL(iShareIndex: Integer; iBufCount : Integer = 15) ; overload ;
		procedure FilterXY(iSXIndex, iSYIndex : Integer) ;

		procedure Save(var fsSave : TFileStream; SaveCnt: Integer) ; overload ;
		function Save(var fsSave : TFileStream; ShareIndex: TShareIndex; smSave : TFaGraphSaveMode) : Boolean ; overload ;
		procedure Load(var fsLoad : TFileStream; LoadCnt: Integer) ; overload ;
		procedure Load(var fsLoad : TFileStream; ShareIndex: TShareIndex; lmLoad : TFaGraphLoadMode) ; overload ;
	end ;

	TSubTickCount = 2..10 ;
	TFaAxisRuler = class(TCollectionItem)
	private
		{ Private declarations }

        FClimping    : Boolean ;
		FDrawMin	: Double;
		FDrawMax	: Double;
		FMin	: Double;
		FMax	: Double;
		FStep 	: Double ;
		FDecimal: Byte ;
		FSubTickCount : TSubTickCount ;
		FCaption	: String ;

		FScale  : TFaAxisScale ;
		FAlign	: TFaAxisAlign ;

		FShowing 	: Boolean ;
		FShowTick	: Boolean ;
		FShowSubTick: Boolean ;
		FShowLabel  : Boolean ;
		FShowCaption: Boolean ;
		FShowLabelCenter: Boolean ;
		FShowFrame  : Boolean ;
		FShowSign   : Boolean ;
		FShowSignMinus   : Boolean ;

        //======
        // LABEL DATA FORMAT
        //===
        FLabelFormat     : String ;
		FTickColor		: TColor ;
		FCaptionColor	: TColor ;
		FRect 			: TFaAxisRect ;

		function GetMax : Double ;
		function GetMin : Double ;

		function GetDrawMax : Double ;
		function GetDrawMin : Double ;

		procedure SetDrawMin(Value : Double) ;
		procedure SetDrawMax(Value : Double) ;
		procedure SetMin(Value : Double) ;
		procedure SetMax(Value : Double) ;
		procedure SetDecimal(Value : Byte) ;
		procedure SetStep(Value : Double);
		procedure SetSubtickCount(Value : TSubTickCount);

		procedure SetCaption(Value : String) ;
		procedure SetShowCaption(Value : Boolean) ;
		procedure SetShowing(Value : Boolean) ;
		procedure SetShowTick(Value : Boolean) ;
		procedure SetShowSubTick(Value : Boolean) ;
		procedure SetShowLabel(Value : Boolean) ;
		procedure SetShowLabelCenter(Value : Boolean) ;
		procedure SetShowFrame(Value : Boolean) ;
		procedure SetShowSign(Value : Boolean) ;
		procedure SetShowSignMinus(Value : Boolean) ;
		procedure SetScale(Value : TFaAxisScale) ;
		procedure SetAlign(Value : TFaAxisAlign) ;

		procedure SetTickColor(Value : TColor) ;
		procedure SetCaptionColor(Value : TColor) ;
        procedure SetFormat(Value : String) ;
	protected
		{ Protected declarations }
		procedure AddScroll  ; overload ;
		procedure AddScroll(Value : Double; gtType : TGraphType = gtScroll)  ; overload ;
	public
		{ Public declarations }
		constructor Create(Collection: TCollection); override;
		destructor Destroy; override;
		procedure Assign(Source: TPersistent); override;

	published
		{ Published declarations }
		property DrawMin			: Double read FDrawMin 	write SetDrawMin stored True ;
		property DrawMax			: Double read FDrawMax 	write SetDrawMax stored True ;
		property Climping  	        : Boolean read FClimping write FClimping stored True ;

		property Min			: Double read FMin 	write SetMin  						nodefault ;
		property Max			: Double read FMax 	write SetMax  						nodefault ;
		property Step			: Double read FStep write SetStep 						nodefault;
		property SubTickCount	: TSubTickCount read FSubTickCount write SetSubTickCount 		nodefault;
		property Decimal		: Byte   read FDecimal write SetDecimal 				nodefault;
        property LabelFormat         : String read FLabelFormat write SetFormat nodefault ;

		property Caption		: String			read FCaption write SetCaption  nodefault;
		property Showing		: Boolean			read FShowing write SetShowing nodefault ;
		property ShowTick  		: Boolean			read FShowTick write SetShowTick nodefault ;
		property ShowSubTick  	: Boolean			read FShowSubTick write SetShowSubTick nodefault ;
		property ShowLabel  	: Boolean			read FShowLabel write SetShowLabel nodefault ;
		property ShowCaption  	: Boolean			read FShowCaption write SetShowCaption nodefault ;
		property ShowLabelCenter  	: Boolean		read FShowLabelCenter write SetShowLabelCenter nodefault ;
		property ShowFrame  	: Boolean			read FShowFrame write SetShowFrame nodefault ;
		property ShowSign  		: Boolean			read FShowSign write SetShowSign nodefault ;
		property ShowSignMinus  : Boolean			read FShowSignMinus write SetShowSignMinus nodefault ;
		property Scale 			: TFaAxisScale     	read FScale write SetScale  nodefault ;
		property Align 			: TFaAxisAlign     	read FAlign write SetAlign  nodefault ;
		property TickColor 		: TColor     		read FTickColor write SetTickColor  nodefault ;
		property CaptionColor 	: TColor     		read FCaptionColor write SetCaptionColor  nodefault ;
	end ;

	TFaAxis = class(TOwnedCollection)
	private
		{ Private declarations }
		FAxisRect   : TRect ;
		FGraphRect  : TRect ;

		Canvas : TCanvas ;

		FFontWidth, FFontHeight : Integer ;

		function GetItem(Index: Integer): TFaAxisRuler;
		procedure SetItem(Index: Integer; Value: TFaAxisRuler);
	protected
		{ Protected declarations }
		FFaGraph : TFaGraphEx ;
		FMaxDatas : Integer ;

		procedure Update(Item: TCollectionItem) ; override ;
	public
		{ Public declarations }
		constructor Create(AOwner: TPersistent);
		destructor  Destroy ; override ;

		function  GetRect() : TRect ;

		function  Add: TFaAxisRuler;

		function  SetInitial(FCanvas : TCanvas; Rect : TRect) : TRect ;

		function  CalcXY(Index: Integer; xy : Integer) : Double ;
		function  GetXY(index : Integer; tick : Double; isLogData : Boolean = false) : Integer ;

		function  GetLeftTop(Index: Integer) : Integer ;
		function  GetRightBottom(Index: Integer) : Integer ;

		function  GetRulerLabel(index : Integer; data : Double) : String ;
		function  GetRulerSize(index : Integer) : Integer ;
		function  Recalc : TRect ;

		procedure DrawRuler ;

		procedure DrawCaption(Index : Integer) ;
		procedure DrawRulerLogX(Index : Integer) ;
		procedure DrawRulerLogY(Index : Integer) ;
		procedure DrawRulerX(index, tick_count : Integer; tick : Double) ;
		procedure DrawRulerY(index, tick_count : Integer; tick : Double) ;
		procedure DrawLabel(Index : Integer) ; overload ;
		procedure DrawLabel(Index : Integer; Value: array of Double; asText: array of String) ; overload ;

		property Items[Index : Integer] : TFaAxisRuler read GetItem write SetItem nodefault ;
	published
		{ Published declarations }
	end;


	TAxisIndexs = array of Integer ;

	TFaSerie = class(TCollectionItem)
	private
		{ Private declarations }
		FXAxis, FYAxis : Integer ;
		FStyles		   : TFaGraphStyle ;
		FPoints        : TFaGraphPoint ;
		FPointsFill	   : Boolean ;
		FPointColor    : TColor ;
		FLineColor     : TColor ;
		FWidth         : Integer ;
		FAutoPointWidth: Boolean ;
		FPointWidth    : Integer ;
		FVisible	   : Boolean ;

		FXShare, FYShare  : TShareIndex  ;

		//function  Paser(aiAxis: TAxisIndexs; arrow: Boolean; var Value : String) : Boolean ;

		procedure SetWidth(Value : Integer) ;
		procedure SetVisible(Value : Boolean) ;
		procedure SetXAxis(Value : Integer) ; overload ;
		procedure SetYAxis(Value : Integer) ; overload ;
		procedure SetXShare(Value : TShareIndex) ; overload ;
		procedure SetYShare(Value : TShareIndex) ; overload ;
		procedure SetStyles(Value: TFaGraphStyle) ;
		procedure SetPoints(Value: TFaGraphPoint) ;
		procedure SetPointsFill(Value: Boolean) ;
		procedure SetPointColor(Value: TColor) ;
		procedure SetLineColor(Value: TColor) ;
		procedure SetPointWidth(Value : Integer) ;
		procedure SetAutoPointWidth(Value : Boolean) ;
	protected
		{ Protected declarations }
		procedure DrawPoint(Canvas: TCanvas; x, y, w, h: Integer; pColor, bColor: TColor) ;
		procedure DrawScrollData(Canvas : TCanvas; Rect: TRect);
		procedure DrawData(Canvas : TCanvas; Rect: TRect);
		procedure DrawViewData(Canvas : TCanvas; Rect: TRect; Start: Integer);
	public
		{ Public declarations }
		constructor Create(Collection: TCollection); override;
		destructor Destroy; override;
		procedure Assign(Source: TPersistent); override;

		procedure AddData(x, y : Double) ; overload ;
		procedure AddData(x, y : array of Double) ; overload ;
		procedure SetData(index: Integer; x, y : Double) ;
		function   GetData(index: Integer; var x, y : Double) : Boolean ;
		function   FindX(var xFind : Double) : Integer ;
		function   FindY(var yFind : Double) : Integer ;
		procedure Empty ;
		procedure DrawLabel(Canvas : TCanvas; Rect: TRect; x, y : Double; asText: String; Color: TColor = clBlack) ;
//		procedure GetXY(Rect: TRect; x, y : Double; var xPos, yPos :Integer) ;

	published
		{ Published declarations }
		property AxisX : Integer read FXAxis write SetXAxis nodefault ;
		property AxisY : Integer read FYAxis write SetYAxis nodefault ;
		property AutoPointWidth : Boolean read FAutoPointWidth write SetAutoPointWidth default True ;
		property PointWidth : Integer read FPointWidth write SetPointWidth nodefault  ;
		property Width : Integer read FWidth write SetWidth default 1 ;
		property ShareX : TShareIndex read FXShare write SetXShare nodefault ;
		property ShareY : TShareIndex read FYShare write SetYShare nodefault ;
		property Styles : TFaGraphStyle read FStyles write SetStyles nodefault ;
		property Points : TFaGraphPoint read FPoints write SetPoints nodefault ;
		property PointsFill : Boolean read FPointsFill write SetPointsFill default true ;
		property LineColor : TColor read FLineColor write SetLineColor nodefault ;
		property PointColor : TColor read FPointColor write SetPointColor nodefault ;
		property Visible : Boolean read FVisible write SetVisible default True ;
	end ;

	TFaSeries = class(TOwnedCollection)
	private
		{ Private declarations }
		function GetItem(Index: Integer): TFaSerie;
		procedure SetItem(Index: Integer; Value: TFaSerie);

		function GetFaAxisCount : Integer ;
	protected
		{ Protected declarations }
		FFaAxis : TFaAxis ;
		FFaGraph : TFaGraphEx ;

		procedure Update(Item: TCollectionItem) ; override ;
		procedure DrawScrollData(Canvas : TCanvas; Rect: TRect); overload ;
		procedure DrawScrollData(Canvas : TCanvas; Rect: TRect; siIndex : array of Integer); overload ;
		procedure DrawData(Canvas : TCanvas; Rect: TRect);
		procedure DrawViewData(Canvas : TCanvas; Rect: TRect; Start: Integer);
	public
		{ Public declarations }
		constructor Create(AOwner: TPersistent);
		destructor  Destroy ; override ;

		function Add: TFaSerie;
		property Items[Index : Integer] : TFaSerie read GetItem write SetItem nodefault ;
		property FaAxisCount : integer read GetFaAxisCount ;

		procedure Empty ;
	published
		{ Published declarations }
	end ;


	TFaGraphSpace = class(TPersistent)
	private
		{ Private declarations }
		FLeft ,
		FRight,
		FTop,
		FBottom	: Integer ;
	public
		{ Public declarations }
	published
		property Left 	: Integer read FLeft write FLeft nodefault ;
		property Right 	: Integer read FRight write FRight nodefault ;
		property Top 	: Integer read FTop write FTop nodefault ;
		property Bottom : Integer read FBottom write FBottom nodefault ;
	end ;

	TDragMode	 = (dmPush, dmStart, dmDragging, dmEnd, dmPop) ;
	TScrollEvent = procedure (Sender: TObject; Rect: TRect) of object;
	TFaGraphEx = class(TGraphicControl)
	private
		{ Private declarations }
        // 버전정보
        FVersion : String ;
		//==========================================
		// 2000년 12월 14일 추가
		//	DRAG 기능
		FDragMode  : TDragMode ;
		FDragStart  : TPoint ;
		FDragStop   : TPoint ;
		//==========================================
		// 2001년 11월 23일 기능제거
		//==========================================
//		FDragAxisX  : TFaAxisRuler ;
//		FDragAxisY  : TFaAxisRuler ;
		FDragDataX  : Double ;
		FDragDataY  : Double ;
		//==========================================
		// 2001년 11월 23일 기능제거
		//==========================================
//		FDragShowSaveX : Boolean ;
//		FDragShowSaveY : Boolean ;

		FZoomMode	: Boolean ;
		FZoomSeries : Integer ;
		//==========================================
		// 2001년 11월 23일 추가
		// ZoomIn/ZoomOut시 화면 깝빡임을 방지하기 위해
		//==========================================
		FRangeXmin, FRangeXmax, FRangeXstep  : Double ;
		FRangeYmin, FRangeYmax, FRangeYstep  : Double ;
		FRangeXdec, FRangeYdec : BYTE ;
		//==========================================
		// 2001년 1월 10일 추가
		//	CrossBar 기능
		FViewCrossBar: Boolean ;
		FViewCrossPoint : TPoint ;
		FViewCrossStatus: Integer ;
		//==========================================
        // 2007.11.01 일정시간이 지나야지만 화면 업데이트하는 기능 추가
        //==========================================
        FUpdateDelayEnabled  : Boolean ;
        FUpdateDelayTime     : Double ;
        FCUpdateDelayTime    : TTimeCount ;

        //==========================================
		FFaAxis 	: TFaAxis ;
		FFaSeries   : TFaSeries ;
		FBorder 	: TBitmap ;
		FBoardColor  : TColor ;
		FGridDraw 	 : TFaGraphGrids ;
		FGridDrawSide 	 : TFaGraphSides ;
		FViewCrossBarDraw 	: TFaGraphGrids ;
		FGridColor  : TColor ;
		FGridStyle  : TPenStyle ;
		FGraphType  : TGraphType ;
		FGridDrawSub  : Boolean ;
		FOutnerFrame	: Boolean ;
		FOutnerFrameColor	: TColor ;

		FViewStart  : Integer ;

		FHRgn		: HRGN ;
		FRect       : TRect ;
		FMaxDatas   : Integer ;

		FSpace		: TFaGraphSpace ;

		FOnChange	: TNotifyEvent;
		FOnPaint	: TNotifyEvent;
		FOnBeforePaint	: TNotifyEvent;
		FOnAfterPaint	: TNotifyEvent;
		FOnScroll 	: TScrollEvent ;

        //----------------------------
        // by sattler for Preview Draw
        //----------------------------
        FUserPreview : boolean ;
        FUserCanvas  : TCanvas ;
        //----------------------------
        // 내부 이미지를 외부 캔버스에 보낼때 속도 감소 현상.
        // 특정 시점동안 그리지 않도록 Lock를 건다.
        //----------------------------
        FLock : boolean ;
        //----------------------------
		procedure SetGridDraw(Value : TFaGraphGrids) ;
		procedure SetGridDrawSide(Value : TFaGraphSides) ;
		procedure SetGridColor(Value : TColor) ;
		procedure SetGridStyle(Value : TPenStyle) ;
		procedure SetGridDrawSub(Value : Boolean) ;
		procedure SetBoardColor(Value : TColor) ;
		procedure SetOutnerFrame(Value : Boolean) ;
		procedure SetOutnerFrameColor(Value : TColor) ;

		procedure SetMaxDatas(Value : Integer) ;
		procedure SetGraphType(Value : TGraphType) ;

		procedure SetSpace(Value : TFaGraphSpace) ;

		procedure SetZoomMode(Value : Boolean) ;
		procedure SetZoomSeries(Value : Integer) ;
		procedure SetViewCrossBar(Value : Boolean) ;
		procedure SetViewCrossBarDraw(Value : TFaGraphGrids) ;

		procedure SetVersion(const Value : String) ;

        procedure SetUpdateDelayEnabled(Value : Boolean) ;
	protected
		{ Protected declarations }
		FUpdateCount : Integer ;
		procedure Paint; Override;
		procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
		procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
		procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
	public
		{ Public declarations }
		FSdShare : TFaShareData ;
		constructor Create(AOwner: TComponent); override;
		destructor Destroy; override;

		procedure  Save(var fsSave : TFileStream; SaveCnt : Integer) ; overload ;
		procedure  Save(var fsSave : TFileStream; iIndex : TShareIndex; smSave : TFaGraphSaveMode) ; overload ;
		procedure  Load(var fsLoad : TFileStream; LoadCnt: Integer) ; overload ;
		procedure  Load(var fsLoad : TFileStream; iIndex : TShareIndex; lmLoad : TFaGraphLoadMode) ; overload ;

		function 	GetDefaultXAxis : Integer ;
		function 	GetDefaultYAxis : Integer ;
		procedure 	View(gvView : TFaGraphView) ;


		procedure Empty ; overload ;
		procedure Empty(SeriesIndex : Integer) ; overload ;
		function  GetBoardRect : TRect ;
		procedure SetBoardRect(Rect : TRect);

		procedure AddData(siIndex: array of Integer; x, y : array of Double) ;
		procedure DrawGrid(Canvas : TCanvas; Rect: TRect); overload ;

		procedure DrawGrid(ggGrid: TFaGraphGrid; Value: array of Double; Rect: TRect; clColor : TColor = clSilver; gsStyle : TPenStyle = psSolid); overload ;
		procedure DrawGrid(xAxis, yAxis : integer; Rect: TRect; ggGrid: TFaGraphGrid; Value: array of Double; clColor : TColor = clSilver; gsStyle : TPenStyle = psSolid); overload ;
		procedure DrawVertLine(xAxis, yAxis : integer; Rect: TRect; xData, yStart, yStop : Double; clColor : TColor; gsStyle : TPenStyle);
		procedure DrawHoriLine(xAxis, yAxis : integer; Rect: TRect; xStart, xStop, yData : Double; clColor : TColor; gsStyle : TPenStyle);

		procedure DrawLabel(Index: Integer; x, y : Double; asText: String; Color: TColor = clBlack) ;
		function GetXY(Index : Integer; x, y: Double; var tempCanvas: TCanvas; var xPos, yPos : Integer) : Boolean ;
		function GetX(Index : Integer; x: Double; var xPos : Integer) : Boolean ;
		function GetY(Index : Integer; y: Double; var yPos : Integer) : Boolean ;

		function GetBoardArea(Index : Integer; var areaRect : TRect) : Boolean;
		function IsBoardXY(Index : Integer; x, y : Integer) : Boolean;
		function IsBoardX(Index : Integer; x : Integer) : Boolean;
		function IsBoardY(Index : Integer; y : Integer) : Boolean;

		function CalcXY(Index : Integer; x, y : Integer; var xData, yData : Double) : Boolean;
		function CalcX(Index : Integer; x : Integer; var xData : Double) : Boolean;
		function CalcY(Index : Integer; y : Integer; var yData : Double) : Boolean;

		function FindXY(Index : Integer; x, y : Integer; var xData, yData : Double) : Boolean; overload ;
		function FindXY(Index : Integer; x, y : Integer; var xData, yData : Double; var xIndex, yIndex : Integer) : Boolean; overload ;
		function FindX(Index : Integer; x : Integer; var xData : Double) : Integer;
		function FindY(Index : Integer; y : Integer; var yData : Double) : Integer;

		//==========================================
		// 2000년 12월 14일 추가
		//	DRAG 기능
		//==========================================
		procedure XorOn() ;
		procedure DragPush() ;
		procedure DragStart(x, y : Integer) ;
		procedure DragEnd(x, y : Integer) ;
		procedure Draging(x, y : Integer) ;
		procedure DragPop() ;
		procedure XorOff() ;
		procedure DrawCrossBar(sIndex, x, y: Integer; barColor : TColor = clBlack; barStyle : TPenStyle = psDot) ;
		procedure onDrawCrossBar(x, y : Integer) ;
		function  GetDragMode() : TDragMode ;

		//==========================================
		procedure GetCanvas(var tempCanvas: TCanvas) ;

		procedure DrawData(siIndex: array of Integer) ; overload ;
		procedure DrawData(Canvas : TCanvas; Rect: TRect); overload ;
		procedure DrawFrame(Canvas : TCanvas; Rect : TRect) ;
		procedure Draw ;
		procedure Print(mCanvas : TCanvas; Rect: TRect; APreview: Boolean = False; ARgn : Boolean = false);

		procedure Update ; override ;
		procedure BeginUpdate;
		procedure EndUpdate;
		property  Canvas;

        // 2005.05.23
        procedure SetLock ;
        procedure SetUnLock ;
        property  Lock: boolean read FLock ;
	published
		{ Published declarations }
		property Axis: TFaAxis read FFaAxis write FFaAxis nodefault;
		property Series: TFaSeries read FFaSeries write FFaSeries nodefault;

		property MaxDatas : Integer read FMaxDatas write SetMaxDatas nodefault ;

		property GridDraw : TFaGraphGrids read FGridDraw write SetGridDraw nodefault;
		property GridDrawSide : TFaGraphSides read FGridDrawSide write SetGridDrawSide nodefault;
		property GridDrawSub : Boolean read FGridDrawSub write SetGridDrawSub nodefault;
		property GridColor: TColor  read FGridColor write SetGridColor nodefault;
		property GridStyle: TPenStyle read FGridStyle write SetGridStyle nodefault;
		property BoardColor: TColor  read FBoardColor write SetBoardColor nodefault;
		property GraphType : TGraphType read FGraphType write SetGraphType nodefault ;

		property OutnerFrame : Boolean read FOutnerFrame write SetOutnerFrame nodefault ;
		property OutnerFrameColor : TColor read FOutnerFrameColor write SetOutnerFrameColor nodefault ;

		property Space : TFaGraphSpace read FSpace write SetSpace nodefault ;
		property Zoom  : Boolean		read FZoomMode write SetZoomMode noDefault ;
		property ZoomSerie  : Integer	read FZoomSeries write SetZoomSeries noDefault ;
		property ViewCrossBar: Boolean	read FViewCrossBar write SetViewCrossBar noDefault ;
		property ViewCrossBarDraw : TFaGraphGrids read FViewCrossBarDraw write SetViewCrossBarDraw nodefault;

        property Version : String read FVersion write SetVersion stored TFaGraphVersion  ;
		//==========================================
        // 2007.11.01 일정시간이 지나야지만 화면 업데이트하는 기능 추가
        //==========================================
        property UpdateDelayTime     : Double read FUpdateDelayTime write FUpdateDelayTime nodefault ;
        property UpdateDelayEnabled  : Boolean read FUpdateDelayEnabled write SetUpdateDelayEnabled ;

		property Anchors;
		property Align;
		property Constraints;
		property Color ;
		property DragCursor;
		property DragMode;
		property Enabled;
		property Font;
		property ParentFont;
		property ParentShowHint;
		property PopupMenu;
		property ShowHint;
		property Visible;

		property OnChange: TNotifyEvent read FOnChange write FOnChange;
		property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
		property OnBeforePaint: TNotifyEvent read FOnBeforePaint write FOnBeforePaint;
		property OnAfterPaint: TNotifyEvent read FOnAfterPaint write FOnAfterPaint;
		property OnScroll: TScrollEvent read FOnScroll write FOnScroll ;
		property OnClick;

		//==========================================
		property OnMouseDown ;
		property OnMouseMove ;
		property OnMouseUp ;
		//==========================================
		//==========================================
		// 2000년 12월 14일 추가
		property Cursor;
		property DragKind;
		property OnDblClick;
		property OnStartDrag;
		property OnDragOver;
		property OnDragDrop;
		property OnEndDrag;
		//==========================================
	end;

procedure Register;

implementation
uses
	Printers, Math, UserMath ;

const
//  LANGUAGE : KOREA
	DegreeSymbol = '˚' ;
	MinuteSymbol = '＇' ;

//  LANGUAGE : ENGLISH
//	DegreeSymbol = #176 ;
//	MinuteSymbol = #180 ;
procedure Register;
begin
	 RegisterComponents('FA', [TFaGraphEx]);
end;

//------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
procedure TextOutCenter(Canvas: TCanvas; x, y: integer; const str: string) ;
var
   ta:    word ;
begin
	 ta := SetTextAlign(Canvas.Handle, TA_CENTER or TA_TOP) ;
	 Canvas.TextOut(x, y - Canvas.TextHeight(str) div 2, str) ;
	 SetTextAlign(Canvas.Handle, ta) ;
end ;

procedure TextOutLeft(Canvas: TCanvas; x, y: integer; const str: string) ;
var
   ta:    word ;
begin
	 ta := SetTextAlign(Canvas.Handle, TA_LEFT or TA_TOP) ;
	 Canvas.TextOut(x, y - Canvas.TextHeight(str) div 2, str) ;
	 SetTextAlign(Canvas.Handle, ta) ;
end ;

procedure TextOutRight(Canvas: TCanvas; x, y: integer; const str: string) ;
var
   ta:    word ;
begin
	 ta := SetTextAlign(Canvas.Handle, TA_RIGHT or TA_TOP) ;
	 Canvas.TextOut(x, y - Canvas.TextHeight(str) div 2, str) ;
	 SetTextAlign(Canvas.Handle, ta) ;
end ;

procedure DrawLine(Canvas: TCanvas; Color: TCOLOR; left, top, right, bottom : integer) ;
var
   OldColor : TColor ;
begin
	 OldColor := Canvas.Pen.Color ;

	 Canvas.Pen.Color := Color ;
	 Canvas.MoveTo(left, top) ;
	 Canvas.LineTo(right, bottom) ;

	 Canvas.Pen.Color := OldColor ;
end ;
procedure DrawVert(Canvas: TCanvas; Color: TCOLOR; left, top, bottom : integer) ;
begin
	 DrawLine(Canvas, Color, left, top, left, bottom) ;
end ;
procedure DrawHori(Canvas: TCanvas; Color: TCOLOR; left, top, right : integer) ;
begin
	 DrawLine(Canvas, Color, left, top, right, top) ;
end ;
procedure DrawBox(Canvas: TCanvas; LColor, RColor: TCOLOR; left, top, right, bottom : integer) ;
begin
	 DrawHori(Canvas, LColor, left, top, right) ;
	 DrawVert(Canvas, RColor, right, top, bottom) ;
	 DrawHori(Canvas, RColor, left, bottom, right) ;
	 DrawVert(Canvas, LColor, left, top, bottom) ;
end ;
procedure DrawBox3D(Canvas: TCanvas; LColor, RColor: TCOLOR; thick, left, top, right, bottom: integer) ;
begin
	 DrawBox(Canvas, LColor, RColor, left, top, right, bottom) ;
	 DrawBox(Canvas, RColor, LColor, left+thick, top+thick, right-thick, bottom-thick) ;
end ;
procedure DrawCircle(Canvas: TCanvas; x, y, w, h: Integer);
begin
	with Canvas do
	begin
    	w := (w shr 1) shl 1 ;
    	h := (h shr 1) shl 1 ;
		Ellipse(x - w, y - h, x + w, y + h);
	end ;
end;
procedure DrawRect(Canvas: TCanvas; x, y, w, h: Integer);
begin
	with Canvas do
	begin
    	w := (w shr 1) shl 1 ;
    	h := (h shr 1) shl 1 ;
		Rectangle(x - w, y - h, x + w, y + h);
	end ;
end;

procedure DrawDiamond(Canvas: TCanvas; x, y, w, h: Integer);
begin
	with Canvas do
	begin
    	w := (w shr 1) shl 1 ;
    	h := (h shr 1) shl 1 ;
		Polygon([Point(x, y - h), Point(x + w, y), Point(x, y + h), Point(x - w, y)]);
	end ;
end;

procedure DrawTUp(Canvas: TCanvas; x, y, w, h: Integer);
begin
	with Canvas do
	begin
    	w := (w shr 1) shl 1 ;
    	h := (h shr 1) shl 1 ;
		Polygon([Point(x, y - h), Point(x - w, y + h), Point(x + w, y + h)]);
	end ;
end;
procedure DrawCross(Canvas: TCanvas; x, y, w, h: Integer);
begin
	with Canvas do
	begin
    	w := (w shr 1) shl 1 ;
    	h := (h shr 1) shl 1 ;

		MoveTo(x - w, y);
		LineTo(x + w, y);
		MoveTo(x, y - h);
		LineTo(x, y + h);
	end ;
end;

procedure DrawTDown(Canvas: TCanvas; x, y, w, h: Integer);
begin
	with Canvas do
	begin
    	w := (w shr 1) shl 1 ;
    	h := (h shr 1) shl 1 ;
		Polygon([Point(x, y + h), Point(x - w, y - h), Point(x + w, y - h)]);
	end ;
end;
procedure DrawTLeft(Canvas: TCanvas; x, y, w, h: Integer);
begin
	with Canvas do
	begin
    	w := (w shr 1) shl 1 ;
    	h := (h shr 1) shl 1 ;

		Polygon([Point(x - w, y), Point(x + w, y - h), Point(x + w, y + h)]);
	end ;
end;
procedure DrawTRight(Canvas: TCanvas; x, y, w, h: Integer);
begin
	with Canvas do
	begin
    	w := (w shr 1) shl 1 ;
    	h := (h shr 1) shl 1 ;

		Polygon([Point(x + w, y), Point(x - w, y - h), Point(x - w, y + h)]);
	end ;
end;
procedure DrawX(Canvas: TCanvas; x, y, w, h: Integer);
begin
	with Canvas do
	begin
    	w := (w shr 1) shl 1 ;
    	h := (h shr 1) shl 1 ;
		MoveTo(x - w, y - h);
		LineTo(x + w, y + h);
		MoveTo(x + w, y - h);
		LineTo(x - w, y + h);
	end ;
end;
//------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
constructor TFaAxisRuler.Create(Collection: TCollection);
begin
	inherited Create(Collection);

	FMin := 0 ;
	FMax := 0 ;

	FDrawMin := 0 ;
	FDrawMax :=  10;

	FStep := 1 ;
	FDecimal := 0 ;
    FLabelFormat := '' ;
    
	FSubTickCount := 10 ;

	Showing     := True  ;
	ShowTick    := True  ;
	ShowSubTick    := True  ;
	ShowLabel   := True  ;
	ShowCaption := True  ;
	ShowLabelCenter := False  ;
	ShowFrame := True  ;
	ShowSign := False  ;
	ShowSignMinus := True  ;
end;
destructor TFaAxisRuler.Destroy ;
begin
	inherited Destroy;
end;


function TFaAxisRuler.GetMax : Double ;
begin
	 if FScale = asLog then	Result := Log10(iPower(10, Trunc(FMax)))
	 else                  	Result := FMax ;
end ;
function TFaAxisRuler.GetMin : Double ;
begin
	 if FScale = asLog then	Result := Log10(iPower(10, Round(FMin)))
	 else                   Result := FMin ;
end ;
function TFaAxisRuler.GetDrawMax : Double ;
begin
    if FClimping then
    begin
	    if FScale = asLog then	Result := Log10(iPower(10, Trunc(FDrawMax)))
	    else                  	Result := FDrawMax ;
    end
    else    Result := GetMax() ;
end ;
function TFaAxisRuler.GetDrawMin : Double ;
begin
    if FClimping then
    begin
	    if FScale = asLog then	Result := Log10(iPower(10, Round(FDrawMin)))
	    else                    Result := FDrawMin ;
    end
    else    Result := GetMin() ;
end ;

procedure TFaAxisRuler.AddScroll(Value : Double; gtType : TGraphType)  ;
var
	w : Double ;
begin
    //======
    // Zero Divide Error 처리용
    //===
    if FMax = FMin then FMax := FMin + 10 ;
    if FStep = 0 then FStep := (FMax - FMin) / 5 ;

	if (gtType = gtScroll) then
	begin
		w := FMax - FMin ;
		FMax := Value;
		FMin := FMax - w ;
	end
	else
	begin
		if Value > GetMax() then
		begin
			w := (FMax - FMin) / FStep ;
			FMax := Value ;
            FStep := (FMax - FMin) / w ;

//			SetStep((FMax - FMin) / w) ;
		end ;
	end ;
end ;

procedure TFaAxisRuler.AddScroll ;
begin
	FMax := FMax + FStep;
	FMin := FMin + FStep;
end ;

procedure TFaAxisRuler.SetDrawMin(Value : Double) ;
begin
	if FDrawMin <> Value then
	begin
		FDrawMin := Value ;
		TFaAxis(GetOwner).Update(Self) ;
	end ;
end ;
procedure TFaAxisRuler.SetDrawMax(Value : Double) ;
begin
	if FDrawMax <> Value then
	begin
		FDrawMax := Value ;
		TFaAxis(GetOwner).Update(Self) ;
	end ;
end ;
procedure TFaAxisRuler.SetMin(Value : Double) ;
begin
	if (FMin <> Value) and (Value <> FMax) then
	begin
		FMin := Value ;
        // ERROR 처리
        if FMin > FMax then FMax := FMin + FStep ;
		TFaAxis(GetOwner).Update(Self) ;
	end ;
end ;
procedure TFaAxisRuler.SetMax(Value : Double) ;
begin
	if (FMax <> Value) and (Value <> FMin) then
	begin
		FMax := Value ;
        // ERROR 처리
        if FMax < FMin then FMin := FMax - FStep ;
		TFaAxis(GetOwner).Update(Self) ;
	end ;
end ;
procedure TFaAxisRuler.SetDecimal(Value : Byte) ;
begin
	if FDecimal <> Value then
	begin
		FDecimal := Value ;
		TFaAxis(GetOwner).Update(Self) ;
	end ;
end ;
procedure TFaAxisRuler.SetFormat(Value : String) ;
begin
	if FLabelFormat <> Value then
	begin
		FLabelFormat := Value ;
		TFaAxis(GetOwner).Update(Self) ;
	end ;
end ;
procedure TFaAxisRuler.SetStep(Value: Double);
begin
	if (FStep <> Value) and (Value > 0) then
	begin
		FStep := Value ;
		if FScale = asLog then FStep := 1 ;
		TFaAxis(GetOwner).Update(Self) ;
    end ;
end ;
procedure TFaAxisRuler.SetSubTickCount(Value: TSubTickCount);
begin
	if FSubTickCount <> Value then
	begin
		FSubTickCount := Value ;
		TFaAxis(GetOwner).Update(Self) ;
	end ;
end ;
procedure TFaAxisRuler.SetCaption(Value : String) ;
begin
	if FCaption <> Value then
	begin
		FCaption := Value ;
		TFaAxis(GetOwner).Update(Self) ;
	end ;
end ;
procedure TFaAxisRuler.SetShowCaption(Value : Boolean) ;
begin
	if FShowCaption <> Value then
	begin
		FShowCaption := Value ;
		TFaAxis(GetOwner).Update(Self) ;
	end ;
end ;
procedure TFaAxisRuler.SetShowLabelCenter(Value : Boolean) ;
begin
	if FShowLabelCenter <> Value then
	begin
		FShowLabelCenter := Value ;
		TFaAxis(GetOwner).Update(Self) ;
	end ;
end ;
procedure TFaAxisRuler.SetShowing(Value : Boolean) ;
begin
	if FShowing <> Value then
	begin
		FShowing := Value ;
		TFaAxis(GetOwner).Update(Self) ;
	end ;
end ;
procedure TFaAxisRuler.SetShowTick(Value : Boolean) ;
begin
	if FShowTick <> Value then
	begin
		FShowTick := Value ;
		TFaAxis(GetOwner).Update(Self) ;
	end ;
end ;
procedure TFaAxisRuler.SetShowSubTick(Value : Boolean) ;
begin
	if FShowSubTick <> Value then
	begin
		FShowSubTick := Value ;
		TFaAxis(GetOwner).Update(Self) ;
	end ;
end ;
procedure TFaAxisRuler.SetShowLabel(Value : Boolean) ;
begin
	if FShowLabel <> Value then
	begin
		FShowLabel := Value ;
		TFaAxis(GetOwner).Update(Self) ;
	end ;
end ;
procedure TFaAxisRuler.SetShowFrame(Value : Boolean) ;
begin
	if FShowFrame <> Value then
	begin
		FShowFrame := Value ;
		TFaAxis(GetOwner).Update(Self) ;
	end ;
end ;
procedure TFaAxisRuler.SetShowSign(Value : Boolean) ;
begin
	if FShowSign <> Value then
	begin
		FShowSign := Value ;
		TFaAxis(GetOwner).Update(Self) ;
	end ;
end ;
procedure TFaAxisRuler.SetShowSignMinus(Value : Boolean) ;
begin
	if FShowSignMinus <> Value then
	begin
		FShowSignMinus := Value ;
		TFaAxis(GetOwner).Update(Self) ;
	end ;
end ;

procedure TFaAxisRuler.SetScale(Value : TFaAxisScale) ;
begin
	if FScale <> Value then
	begin
		FScale := Value ;
//		if Value = asDate then FDecimal := 4 ;
//		if (Value = asTime) or (Value = asDateTime) then FDecimal := 5 ;
		TFaAxis(GetOwner).Update(Self) ;
	end ;
end ;
procedure TFaAxisRuler.SetAlign(Value : TFaAxisAlign) ;
begin
	if FAlign <> Value then
	begin
		FAlign := Value ;
		TFaAxis(GetOwner).Update(Self) ;
	end ;
end ;
procedure TFaAxisRuler.SetTickColor(Value : TColor) ;
begin
	if FTickColor <> Value then
	begin
		FTickColor := Value ;
		TFaAxis(GetOwner).Update(Self) ;
	end ;
end ;
procedure TFaAxisRuler.SetCaptionColor(Value : TColor) ;
begin
	if FCaptionColor <> Value then
	begin
		FCaptionColor := Value ;
		TFaAxis(GetOwner).Update(Self) ;
	end ;
end ;

procedure TFaAxisRuler.Assign(Source: TPersistent);
var
	arRuler : TFaAxisRuler ;
begin
	if (Source is TFaAxisRuler) and (Source <> nil) then
	begin
		arRuler := TFaAxisRuler(Source) ;

		Caption 	:= arRuler.Caption ;

		Showing     := arRuler.Showing  ;
		ShowTick    := arRuler.ShowTick ;
		ShowSubTick := arRuler.ShowSubTick ;
		ShowLabel   := arRuler.ShowLabel ;
		ShowLabelCenter   := arRuler.ShowLabelCenter ;
		ShowCaption := arRuler.ShowCaption ;
		ShowFrame   := arRuler.ShowFrame ;
		ShowSign    := arRuler.ShowSign ;
		ShowSignMinus    := arRuler.ShowSignMinus ;
		Scale       := arRuler.Scale ;
		Align       := arRuler.Align ;
		TickColor   := arRuler.TickColor ;
		CaptionColor:= arRuler.CaptionColor ;

		SubTickCount 	:= arRuler.SubTickCount ;
		DrawMin         := arRuler.DrawMin ;
		DrawMax         := arRuler.DrawMax ;

		Min         := arRuler.Min ;
		Max         := arRuler.Max ;
		Step        := arRuler.Step ;
		Decimal     := arRuler.Decimal ;
        LabelFormat      := arRuler.LabelFormat ;
		Exit;
	end;
	inherited Assign(Source);
end;

//------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
constructor TFaAxis.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TFaAxisRuler);
end;
destructor TFaAxis.Destroy ;
begin
	inherited Destroy;
end;

function TFaAxis.GetRect() : TRect ;
begin
	Result := FGraphRect ;
end ;

function TFaAxis.SetInitial(FCanvas : TCanvas; Rect: TRect) : TRect ;
begin
	Canvas := FCanvas ;
	FAxisRect := Rect ;
	FFontWidth  := Canvas.TextWidth('W') ;
	FFontHeight := Canvas.TextHeight('H') ;

	if FFontHeight > FFontWidth then FFontWidth := FFontHeight
	else                             FFontHeight:= FFontWidth  ;
	Result := Recalc ;
end ;

function TFaAxis.Add: TFaAxisRuler;
begin
	Result := TFaAxisRuler(inherited Add);
end;
function TFaAxis.GetItem(Index: Integer) : TFaAxisRuler;
begin
	Result := TFaAxisRuler(inherited Items[Index]);
end;
procedure TFaAxis.SetItem(Index: Integer; Value: TFaAxisRuler);
begin
	inherited SetItem(Index, TCollectionItem(Value));
end ;

procedure TFaAxis.Update(Item: TCollectionItem) ;
begin
	if FFaGraph <> nil then FFaGraph.Update ;
	(*
	if FFaGraph.FUpdateCount = 0 then
	begin
//		if Canvas <> nil then DrawRuler ;
//		FFaGraph.Draw ;
		FFaGraph.Invalidate
	end ;
	*)
end;

function TFaAxis.GetXY(Index: Integer; tick : Double; isLogData : Boolean) : Integer ;
begin
	with Items[index] do
	begin
		try
            //======
            // Zero Divide Error 처리용
            //===
            if FMax = FMin then FMax := FMin + 10 ;
            if FStep = 0 then FStep := (FMax - FMin) / 5 ;

			if (FScale = asLog) and isLogData then tick := Log10(tick) ;
			if Align in [aaTop, aaBottom, aaHoriCenter] then
				Result := Trunc((tick - GetMin()) * (FRect.Length / (GetMax() - GetMin())))
			else
				Result := Trunc((tick - GetMin()) * (FRect.Length / (GetMax() - GetMin())));
		except
			Result := 0 ;
		end ;
	end ;
end ;
function TFaAxis.CalcXY(Index: Integer; xy : Integer) : Double ;
begin
	with Items[index] do
	begin
		try
            //======
            // Zero Divide Error 처리용
            //===
            if FMax = FMin then FMax := FMin + 10 ;
            if FStep = 0 then FStep := (FMax - FMin) / 5 ;

			if Align in [aaTop, aaBottom, aaHoriCenter] then
				Result := (xy / (FRect.Length / (GetMax() - GetMin()))) + GetMin()
			else
				Result := (xy / (FRect.Length / (GetMax() - GetMin()))) + GetMin() ;
		except
			Result := 0 ;
		end ;
	end ;
end ;

function TFaAxis.GetLeftTop(Index: Integer) : Integer ;
begin
	with Items[index] do
	begin
		Result := 0 ;
	end ;
end ;
function TFaAxis.GetRightBottom(Index: Integer) : Integer ;
begin
	with Items[index] do
	begin
        //======
        // Zero Divide Error 처리용
        //===
        if FMax = FMin then FMax := FMin + 10 ;
        if FStep = 0 then FStep := (FMax - FMin) / 5 ;
		try
			if Align in [aaTop, aaBottom, aaHoriCenter] then
				Result := Trunc((GetMax() - GetMin()) * (FRect.Length / (GetMax() - GetMin())))
			else
				Result := Trunc((GetMax() - GetMin()) * (FRect.Length / (GetMax() - GetMin())));
		except
			Result := 0 ;
		end ;
	end ;
end ;
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
function TFaAxis.GetRulerLabel(index : Integer; data : Double) : String ;
	procedure deg2min(angle : Currency; var D, M, S: Integer) ;
	var
		sign		   : integer ;
	begin
		if angle >= 0 then 	sign := 1
		else				sign := -1 ;
		angle := Abs(angle) ;

		D := Trunc(angle) ;

		angle := (angle - D) * 60 ;
		M := Trunc(angle)  ;

		angle := (angle - M) * 60 ;
		S := Trunc(angle) ;

		D := D * sign ;
	end ;
var
	degree, minute, second : Integer ;
begin
	Result := '' ;
	with Items[index] do
	begin
		if not Showing then Exit ;

		if ShowLabel then
		begin
            if Length(FLabelFormat) > 0 then
            begin
                case Scale of
                    asNormal:
                        begin
                            if not ShowSignMinus then data := Abs(data) ;
                            Result := FormatFloat(LabelFormat, data) ;
                            if ShowSign then
                            begin
                                if Result[1] <> '-' then Result := '+' + Result ;
                            end ;
                        end ;
                    asLog:
                        Result := TorrToString(VoltToTorr(data, Decimal)) ;

                    asDate, asDateMD, asTime, asTimeHM, asDateTime:
                        Result := FormatDateTime(LabelFormat, TDateTime(data))  ;

                    asDegree:
                        Result := FormatFloat(LabelFormat, data) + DegreeSymbol ;

                    asAngle:
                    begin
                        deg2min(data, degree, minute, second) ;

                        Result := IntToStr(degree) + DegreeSymbol;
                        if (Decimal > 0) then	Result := Result + Format('%2.2d', [minute]) + MinuteSymbol;
                        if (Decimal > 2) then	Result := Result + IntToStr(second) ;
                    end ;
                end ;
            end
            else
            begin
                case Scale of
                    asNormal:
                        begin
                            if not ShowSignMinus then data := Abs(data) ;
                            Result := Format('%.*f', [Decimal, data]) ;
                            if ShowSign then
                            begin
                                if Result[1] <> '-' then Result := '+' + Result ;
                            end ;
                        end ;
                    asLog:
                        Result := TorrToString(VoltToTorr(data, Decimal)) ;
                    asDate:
                        Result := FormatDateTime('yyyy.mm.dd', TDateTime(data))  ;
                    asDateMD:
                        Result := FormatDateTime('mm.dd', TDateTime(data))  ;
                    asTime:
                        Result := FormatDateTime('hh:nn:ss', TDateTime(data)) ;
                    asTimeHM:
                        Result := FormatDateTime('hh:nn', TDateTime(data)) ;
                    asDateTime:
                        Result := FormatDateTime('yyyy.mm.dd#hh:nn:ss', TDateTime(data))  ;
                    asDegree:
                        Result := Format('%.*f', [Decimal, data]) + DegreeSymbol ;
                    asAngle:
                    begin
                        deg2min(data, degree, minute, second) ;

                        Result := IntToStr(degree) + DegreeSymbol;
                        if (Decimal > 0) then	Result := Result + Format('%2.2d', [minute]) + MinuteSymbol;
                        if (Decimal > 2) then	Result := Result + IntToStr(second) ;
                    end ;
                end ;
            end ;
		end ;
	end ;
end ;

function TFaAxis.GetRulerSize(index: Integer) : Integer ;
var
	Size : Integer ;
	asRuler : String ;
begin
	Size := 0 ;
	Result := 0 ;
	with Items[index] do
	begin
		if not Showing then Exit ;
		case Align of
			aaLeft,
			aaRight,
			aaVertCenter:
			begin
				if ShowLabel then
				begin
					asRuler := GetRulerLabel(index, GetMax()) ;
					if Pos('#', asRuler) > 0 then asRuler := Copy(asRuler, 1, Pos('#', asRuler) - 1) ;
					Size := Canvas.TextWidth(asRuler) + (FFontWidth div 2);
				end ;
				if ShowTick then Inc(Size, FFontWidth) ;
			end ;
			aaTop,
			aaBottom,
			aaHoriCenter:
			begin
				if ShowLabel then Size := FFontHeight ;
				if ShowTick then Inc(Size, FFontHeight) ;
			end ;
		end ;
	end ;
	Result := Size ;
end ;

procedure TFaAxis.DrawLabel(Index : Integer; Value: array of Double; asText: array of String) ;
var
	c, x, y, h, w, sign : Integer ;

	sFColor : TColor ;
begin
	if Canvas = nil then Exit ;
	with Items[index], Canvas do
	begin
		sFColor := Canvas.Font.Color ;

		Canvas.Font.Color := TickColor ;
		case Align of
			aaTop, aaBottom, aaHoriCenter :
			begin
				if Align = aaTop then	sign := -1
				else                    sign := 1 ;

				h  := FFontHeight * sign;
				y := FRect.Top + Trunc(h * 1.5) ;

				for c := 0 to High(Value) do
				begin
					if c <= High(asText) then
					begin
						x := FRect.Left + GetXY(index, Value[c]) ;
						TextOutCenter(Canvas, x, y, asText[c]) ;
					end ;
				end ;
			end ;
			aaLeft, aaRight, aaVertCenter:
			begin
				if Align = aaRight then	sign := 1
				else                    sign := -1 ;

				w := FFontWidth * sign ;

				if not ShowTick then x := FRect.Left
				else                 x := FRect.Left + w ;

				for c := 0 to High(Value) do
				begin
					if c <= High(asText) then
					begin
						y := (FRect.Top + FRect.Length) - GetXY(index, Value[c]) ;
						if Align = aaRight then TextOutLeft(Canvas, x, y, asText[c])
						else                    TextOutRight(Canvas, x, y, asText[c]) ;
					end ;
				end ;
			end ;
		end ;

		Canvas.Font.Color := sFColor ;
	end ;
end ;
procedure TFaAxis.DrawLabel(Index : Integer) ;
var
	x, y, h, w, sign : Integer ;

	Value, cV, sV 	: Double ;
	torr	: string ;

	sFColor : TColor ;
	asRuler : String ;
begin
	if Canvas = nil then Exit ;
	with Items[index], Canvas do
	begin
		if not ShowLabel then Exit ;

		cV := (GetMax() + GetMin()) / 2 ;
		sV := (Step / SubTickCount) / 2 ;

		sFColor := Canvas.Font.Color ;

		Canvas.Font.Color := TickColor ;

		case Align of
			aaTop, aaBottom, aaHoriCenter:
			begin
				if Align = aaTop then	sign := -1
				else                    sign := 1 ;

				h  := FFontHeight * sign;
				y := FRect.Top + Trunc(h * 1.5) ;
				Value := GetMin() ;
				while Value < GetMax() + Step do
				begin
					asRuler := GetRulerLabel(index, Value) ;
					if Pos('#', asRuler) > 0 then torr := ' ' + Copy(asRuler, 1, Pos('#', asRuler) - 1) + ' '
					else						  torr := ' ' + asRuler + ' ';
					x := FRect.Left + GetXY(index, Value) ;
					if (Align = aaHoriCenter) then
					begin
						if (Value > 0) then h  := FFontHeight
						else				h  := -FFontHeight ;
						y := FRect.Top + Trunc(h * 1.5) ;
					end ;
					if ((Align = aaHoriCenter) and (not ShowLabelCenter)) then
					begin
						if (Value < cV - sV) or (Value > cV + sV) then
						begin
							TextOutCenter(Canvas, x, y, torr) ;
							if Pos('#', asRuler) > 0 then
							begin
								torr := ' ' + Copy(asRuler, Pos('#', asRuler) + 1, Length(asRuler)) + ' ';
								TextOutCenter(Canvas, x, y + Canvas.TextHeight('H'), torr)
							end ;
						end ;
					end
					else
					begin
						TextOutCenter(Canvas, x, y, torr) ;
						if Pos('#', asRuler) > 0 then
						begin
							torr := ' ' + Copy(asRuler, Pos('#', asRuler) + 1, Length(asRuler)) + ' ';
							TextOutCenter(Canvas, x, y + Canvas.TextHeight('H'), torr)
						end ;
					end ;
					Value := Value + Step ;
				end ;
			end ;
			aaLeft, aaRight, aaVertCenter:
			begin
				if Align = aaRight then	sign := 1
				else                    sign := -1 ;

				w := FFontWidth * sign ;
				x := FRect.Left + w ;
				Value := GetMin() ;
				while Value < GetMax() + Step do
				begin
					y := (FRect.Top + FRect.Length) - GetXY(index, Value) ;
					asRuler := GetRulerLabel(index, Value) ;
					if Pos('#', asRuler) > 0 then torr := ' ' + Copy(asRuler, 1, Pos('#', asRuler) - 1) + ' '
					else						  torr := ' ' + asRuler + ' ';

					if (Align = aaVertCenter) then
					begin
						if (Value > 0) then w  := -FFontWidth
						else				w  := FFontHeight ;
						x := FRect.Left + w ;
					end ;
					if ((Align = aaVertCenter) and (not ShowLabelCenter)) then
					begin
						if (Value < cV - sV) or (Value > cV + sV) then
						begin
							if Value > 0 then	TextOutLeft(Canvas, x, y, torr)
							else                TextOutRight(Canvas, x, y, torr) ;
							if Pos('#', asRuler) > 0 then
							begin
								torr := ' ' + Copy(asRuler, Pos('#', asRuler) + 1, Length(asRuler)) + ' ';
								if Value > 0 then	TextOutLeft(Canvas, x, y + Canvas.TextHeight('H'), torr)
								else                TextOutRight(Canvas, x, y + Canvas.TextHeight('H'), torr) ;
							end ;
						end ;
					end
					else
					begin
						if Align = aaRight then	TextOutLeft(Canvas, x, y, torr)
						else                    TextOutRight(Canvas, x, y, torr) ;
						if Pos('#', asRuler) > 0 then
						begin
							torr := ' ' + Copy(asRuler, Pos('#', asRuler) + 1, Length(asRuler)) + ' ';
							if Align = aaRight then	TextOutLeft(Canvas, x, y + Canvas.TextHeight('H'), torr)
							else                	TextOutRight(Canvas, x, y + Canvas.TextHeight('H'), torr) ;
						end ;
					end ;

					Value := Value + Step ;
				end ;
			end ;
		end ;

		Canvas.Font.Color := sFColor ;
	end ;
end ;

procedure TFaAxis.DrawRulerLogX(Index : Integer) ;
var
	i, x, y, h, h2, sign : Integer ;

	mantissa, Volt, Value 	: Double ;
	torr	: string ;
	pminus, exponent	  : integer ;
begin
	with Items[index], Canvas do
	begin
		if Align = aaTop then	sign := -1
		else                    sign := 1 ;

		h  := FFontHeight * sign;
		h2 := Trunc(h * 0.5) ;
		y := FRect.Top  ;

		Value := GetMin() ;
		while Value < GetMax() + Step do
		begin
			x := FRect.Left + GetXY(index, Value) ;
			torr := GetRulerLabel(index, Value) ;
			if ShowLabel then
			begin
				TextOutCenter(Canvas, x, y + Trunc(h * 1.5), torr) ;
			end ;

			if ShowTick then
			begin
				if Align = aaHoriCenter then
					DrawVert(Canvas, TickColor, x, y - h, y + h)
				else
					DrawVert(Canvas, TickColor, x, y, y + h) ;
				if (ShowSubTick) and (Value < GetMax()) then
				begin
					pminus := Pos('-', torr) ;
					if pminus = 0 then pminus := Pos('+', torr) ;
					exponent := StrToInt(Copy(torr, pminus, Length(torr))) ;
					mantissa := iPower(10, exponent) ;
					for i := 2 to 9 do
					begin
						Volt := Log10(mantissa * i) ;
						x := FRect.Left + GetXY(index, Volt) ;
						if Align = aaHoriCenter then
							DrawVert(Canvas, TickColor, x, y - h2, y + h2)
						else
							DrawVert(Canvas, TickColor, x, y, y + h2) ;
					end ;
				end ;
			end ;
			Value := Value + Step ;
		end ;
	end ;
end ;
procedure TFaAxis.DrawRulerLogY(Index : Integer) ;
var
	i, x, y, w, w2, sign : Integer ;

	mantissa, Volt, Value 	: Double ;
	torr	: string ;
	pminus, exponent	  : integer ;
begin
	with Items[index], Canvas do
	begin
		if Align = aaRight then	sign := 1
		else                    sign := -1 ;

		w := FFontWidth * sign ;
		w2 := Trunc(w * 0.5) ;

		x := FRect.Left ;
		Value := GetMin() ;
		while Value < GetMax() + Step do
		begin
			y := (FRect.Top + FRect.Length) - GetXY(index, Value) ;
			torr := GetRulerLabel(index, Value) ;
			if ShowLabel then
			begin
				if Align = aaRight then	TextOutLeft(Canvas, x + w, y, torr)
				else                    TextOutRight(Canvas, x + w, y, torr) ;
			end ;

			if ShowTick then
			begin
				if Align = aaVertCenter then
					DrawHori(Canvas, TickColor, x - w, y, x + w)
				else
					DrawHori(Canvas, TickColor, x, y, x + w) ;
				if (ShowSubTick) and (Value < GetMax()) then
				begin
					pminus := Pos('-', torr) ;
					if pminus = 0 then pminus := Pos('+', torr) ;
					exponent := StrToInt(Copy(torr, pminus, Length(torr))) ;
					mantissa := iPower(10, exponent) ;
					for i := 2 to 9 do
					begin
						Volt := Log10(mantissa * i) ;
						y := (FRect.Top + FRect.Length) - GetXY(index, Volt) ;
						if Align = aaVertCenter then
							DrawHori(Canvas, TickColor, x - w2, y, x + w2)
						else
							DrawHori(Canvas, TickColor, x, y, x + w2) ;
					end ;
				end ;
			end ;
			Value := Value + Step ;
		end ;
	end ;
end ;
//---------------------------------------------------------------------------
procedure TFaAxis.DrawRulerX(Index, tick_count: Integer; tick : Double) ;
var
	x, y, h, sign : Integer ;
	torr, asRuler : String ;
begin
	try
		with Items[index], Canvas do
		begin
            {
			if (TFaGraphEx(GetOwner).GraphType = gtNormal) then
            begin
                if ((tick < GetDrawMin()) or (tick > GetDrawMax())) then Exit ;
            end ;
            }
			//if {(Scale = asNormal) and }(TFaGraphEx(GetOwner).GraphType = gtNormal) and ((tick < GetDrawMin()) or (tick > GetDrawMax())) then Exit ;
			if ((tick < GetDrawMin()) or (tick > GetDrawMax())) then Exit ;
			if Align = aaTop then	sign := -1
			else                    sign := 1 ;

			h := FFontHeight ;
			x := FRect.Left + GetXY(index, tick) ;
			y := FRect.Top  ;
			if (tick_count mod SubTickCount) = 0 then
			begin
				h := h * sign ;
				if ShowTick then
				begin
					if Align = aaHoriCenter then
						DrawVert(Canvas, TickColor, x, y - h, y + h)
					else
						DrawVert(Canvas, TickColor, x, y, y + h) ;
				end ;
				if ShowLabel and not ((Align = aaHoriCenter) and not ShowLabelCenter and (tick = 0)) then
				begin
					if (Align = aaHoriCenter) and (tick < 0) then   h := Trunc(-Abs(h) * 1.5)
					else											h := Trunc(h * 1.5) ;

					asRuler := GetRulerLabel(index, tick) ;
					if Pos('#', asRuler) > 0 then torr := Copy(asRuler, 1, Pos('#', asRuler) - 1)
					else						  torr := asRuler ;
					TextOutCenter(Canvas, x, y + h, torr) ;
					if Pos('#', asRuler) > 0 then
					begin
						TextOutCenter(Canvas, x, y + h + Canvas.TextHeight('H'), Copy(asRuler, Pos('#', asRuler) + 1, Length(asRuler)))
					end ;
				end ;
			end
			else
			begin
				if ShowSubTick then
				begin
					h := Trunc(h * 0.75) ;
					if (SubTickCount = 10) and ((tick_count mod (SubTickCount div 2)) = 0) then
					begin
						h := h * sign ;
						if ShowTick then
						begin
							if Align = aaHoriCenter then
								DrawVert(Canvas, TickColor, x, y - h, y + h)
							else
								DrawVert(Canvas, TickColor, x, y, y + h) ;
						end ;
					end
					else
					begin
						h := Trunc(h * 0.5) ;
						h := h * sign ;
						if ShowTick then
						begin
							if Align = aaHoriCenter then
								DrawVert(Canvas, TickColor, x, y - h, y + h)
							else
								DrawVert(Canvas, TickColor, x, y, y + h) ;
						end ;
					end ;
				end ;
			end ;
		end ;
	except ;
	end ;
end ;
procedure TFaAxis.DrawRulerY(Index, tick_count: Integer; tick : Double) ;
var
	x, y, w, sign : Integer ;
	torr, asRuler : String ;
begin
	try
		with Items[index], Canvas do
		begin
			if {(Scale = asNormal) and }((tick < GetDrawMin()) or (tick > GetDrawMax())) then Exit ;
			if Align = aaRight then	sign := 1
			else                    sign := -1 ;

			w := FFontWidth ;
			x := FRect.Left ;
			y := (FRect.Top + FRect.Length) - GetXY(index, tick) ;
			if (tick_count mod SubTickCount) = 0 then
			begin
				w := w * sign ;
				if ShowTick then
				begin
					if Align = aaVertCenter then
						DrawHori(Canvas, TickColor, x - w, y, x + w)
					else
						DrawHori(Canvas, TickColor, x, y, x + w) ;
				end ;
				if ShowLabel and not ((Align = aaVertCenter) and not ShowLabelCenter and (tick = 0)) then
				begin
					if ((Align = aaVertCenter) and (tick < 0)) then w := Abs(w) ;

					asRuler := GetRulerLabel(index, tick) ;
					if Pos('#', asRuler) > 0 then torr := Copy(asRuler, 1, Pos('#', asRuler) - 1)
					else						  torr := asRuler ;
					if (Align = aaRight) or ((Align = aaVertCenter) and (tick < 0)) then
						TextOutLeft(Canvas, x + w, y, torr)
					else
						TextOutRight(Canvas, x + w, y, torr) ;
					if Pos('#', asRuler) > 0 then
					begin
						if (Align = aaRight) or ((Align = aaVertCenter) and (tick < 0)) then
							TextOutLeft(Canvas, x + w, y + Canvas.TextHeight('H'), Copy(asRuler, Pos('#', asRuler) + 1, Length(asRuler)))
						else
							TextOutRight(Canvas, x + w, y + Canvas.TextHeight('H'), Copy(asRuler, Pos('#', asRuler) + 1, Length(asRuler))) ;
					end ;
				end ;
			end
			else
			begin
				if ShowSubTick then
				begin
					w := Trunc(w * 0.75) ;
					if (SubTickCount = 10) and ((tick_count mod (SubTickCount div 2)) = 0) then
					begin
						w := w * sign ;
						if ShowTick then
						begin
							if Align = aaVertCenter then
								DrawHori(Canvas, TickColor, x - w, y, x + w)
							else
								DrawHori(Canvas, TickColor, x, y, x + w) ;
						end ;
					end
					else
					begin
						w := Trunc(w * 0.5) ;
						w := w * sign ;
						if ShowTick then
						begin
							if Align = aaVertCenter then
								DrawHori(Canvas, TickColor, x - w, y, x + w)
							else
								DrawHori(Canvas, TickColor, x, y, x + w) ;
						end ;
					end ;
				end ;
			end ;
		end ;
	except ;
	end ;
end ;
procedure TFaAxis.DrawCaption(Index : Integer) ;
var
	x, y, w, h, l : Integer ;
	sFColor : TColor ;
begin
	with Items[index] do
	begin
		if ShowCaption then
		begin
			sFColor := Canvas.Font.Color ;
			Canvas.Font.Color := CaptionColor ;

			w := FRect.Width ;
			h := FFontHeight ;
			x := FRect.Left  ;
			y := FRect.Top ;
			l := FRect.Length ;
			case Align of
				aaLeft, aaVertCenter:
					TextOutCenter(Canvas, x - w div 2, y - h, Caption) ;
				aaRight:
					TextOutCenter(Canvas, x + w div 2, y - h, Caption) ;
				aaTop:
					TextOutCenter(Canvas, x + l div 2, y - Trunc(h * 2.5), Caption) ;
				aaBottom, aaHoriCenter:
					TextOutCenter(Canvas, x + l div 2, y + Trunc(h * 2.5), Caption) ;
			end ;
			Canvas.Font.Color := sFColor ;
		end ;
	end ;
end ;

procedure TFaAxis.DrawRuler ;
var
	x, y, w, index, tick_count : Integer ;
	sV, cV, tick, subTick  : Double ;
	sFColor, sPColor : TColor ;
begin
	sFColor := Canvas.Font.Color ;
	sPColor := Canvas.Pen.Color ;

	SetBkMode(Canvas.Handle, TRANSPARENT) ;
	for index := 0 to Count - 1 do
	begin
		with Items[index] do
		begin
			if not Showing then Continue ;

			subTick := Step / SubTickCount ;
			cV := (GetMax() + GetMin()) / 2 ;
			sV := subTick / 2 ;

			Canvas.Font.Color := TickColor ;
			Canvas.Pen.Color := TickColor ;
			DrawCaption(index) ;
			case Align of
				aaLeft, aaRight, aaVertCenter:
				begin
					x := FRect.Left;
					y := FRect.Top ;
					w := FRect.Top + FRect.Length ;

					if ShowFrame then DrawVert(Canvas, TickColor, x, y, w) ;
					if Scale = asLog then
					begin
						DrawRulerLogY(Index) ;
					end
					else
					begin
						tick := GetMin() ;
						tick_count := -1 ;
						while (tick <= GetMax() - subTick) do
						begin
							Inc(tick_count) ;
							tick := GetMin() + tick_count * subTick ;

							if ((tick_count mod SubTickCount) = 0) and (tick > cV - sV) and (tick < cV + sV) then
							begin
								if (Align = aaVertCenter) and not ShowLabelCenter then Continue ;
							end ;
							DrawRulerY(index, tick_count, tick) ;
						end ;
						if (tick_count mod SubTickCount) <> 0 then DrawRulerY(index, 0, GetMax()) ;
//						DrawRulerY(index, 0, GetMax()) ;
					end ;
				end ;
				aaTop, aaBottom, aaHoriCenter:
				begin
					x := FRect.Left ;
					y := FRect.Top ;
					w := FRect.Left + FRect.Length ;

					if ShowFrame then DrawHori(Canvas, TickColor, x, y, w) ;
					if Scale = asLog then
					begin
						DrawRulerLogX(Index) ;
					end
					else
					begin
						tick := GetMin() ;
						tick_count := -1 ;
						while (tick <= GetMax() - subTick) do
						begin
							Inc(tick_count) ;
							tick := GetMin() + tick_count * subTick ;
							if ((tick_count mod SubTickCount) = 0) and (tick > cV - sV) and (tick < cV + sV) then
							begin
								if (Align = aaHoriCenter) and not ShowLabelCenter then Continue ;
							end ;
							DrawRulerX(index, tick_count, tick) ;
						end ;
						if (tick_count mod SubTickCount) <> 0 then DrawRulerX(index, 0, GetMax()) ;
//						DrawRulerX(index, 0, GetMax()) ;
					end ;
				end ;
			end ;
		end ;
	end ;
	SetBkMode(Canvas.Handle, OPAQUE) ;
	Canvas.Font.Color := sFColor ;
	Canvas.Pen.Color := sPColor ;
end ;

function TFaAxis.Recalc : TRect ;
var
	index : Integer ;
begin
	FGraphRect := FAxisRect ;
	with FGraphRect do
	begin
		Inc(Left, FFontWidth) ;
		Inc(Top,  FFontHeight) ;
		Dec(Right, FFontWidth) ;
		Dec(Bottom, FFontHeight) ;
	end ;

	for index := Count - 1 downto 0 do
	begin
		with Items[index] do
		begin
			if not Showing then Continue ;

			FRect.Width := GetRulerSize(index) ;
			case Align of
				aaLeft:
				begin
					if ShowCaption then
						if Canvas.TextWidth(Caption) > FRect.Width then
							FRect.Width := Canvas.TextWidth(Caption) + (FFontWidth div 2);
					Inc(FGraphRect.Left, FRect.Width) ;
					FRect.Left 	:= FGraphRect.Left - 2 ;
				end ;
				aaRight:
				begin
					if ShowCaption then
						if Canvas.TextWidth(Caption) > FRect.Width then
							FRect.Width := Canvas.TextWidth(Caption) + (FFontWidth div 2);
					Dec(FGraphRect.Right, FRect.Width) ;
					FRect.Left 	:= FGraphRect.Right + 2 ;
				end ;
				aaTop:
				begin
					if ShowCaption then
						Inc(FRect.Width, FFontHeight + (FFontHeight div 2));
					Inc(FGraphRect.Top, FRect.Width) ;
					FRect.Top 	:= FGraphRect.Top - 2 ;
				end ;
				aaBottom:
				begin
					if ShowCaption then
						Inc(FRect.Width, FFontHeight);
					Dec(FGraphRect.Bottom, FRect.Width) ;
					FRect.Top 	:= FGraphRect.Bottom + 2;
				end ;
			end ;
		end ;
	end ;
	for index := Count - 1 downto 0 do
	begin
		with Items[index] DO
		begin
			case Align of
				aaLeft, aaRight:
				begin
					FRect.Top 	:= FGraphRect.Top ;
					FRect.Length:= FGraphRect.Bottom - FGraphRect.Top ;
//						FRect.Length:= FGraphRect.Bottom - FGraphRect.Top + 1;
				end ;
				aaTop, aaBottom:
				begin
					FRect.Left 	:= FGraphRect.Left ;
					FRect.Length:= FGraphRect.Right - FGraphRect.Left ;
				end ;
				aaVertCenter:
				begin
					FRect.Left 	:= FGraphRect.Left + (FGraphRect.Right - FGraphRect.Left + 1) div 2 ;
					FRect.Top 	:= FGraphRect.Top ;
					FRect.Length:= FGraphRect.Bottom - FGraphRect.Top ;
				end ;
				aaHoriCenter:
				begin
					FRect.Left 	:= FGraphRect.Left  ;
					FRect.Top 	:= FGraphRect.Top + (FGraphRect.Bottom - FGraphRect.Top + 1) div 2 ;
					FRect.Length:= FGraphRect.Right - FGraphRect.Left ;
				end ;
			end ;
		end ;
	end ;
	Result := FGraphRect ;
end ;



//------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
constructor TFaShareData.Create ;
var
	index : Integer ;
begin
	inherited Create ;
	FMaxDatas 	:= 0 ;
	FGraphType  := gtNormal ;

	for index := 0 to High(FDatas) do FDatas[index] := TList.Create ;
end;
destructor TFaShareData.Destroy ;
var
	i, index : integer ;
begin
	for index := 0 to High(FDatas) do
	begin
		if FDatas[index] <> nil then
		begin
			with FDatas[index] do
			begin
				for i := Count - 1 downto 0 do
				begin
					Dispose(Items[i]) ;
					Items[i] := nil ;
				end ;
				Clear() ;
				Free() ;
			end ;
		end ;
	end ;
	inherited Destroy;
end;

procedure TFaShareData.SetValue(iMax : Integer; gtType : TGraphType) ;
var
	ShareIndex : Integer ;
begin
	if FMaxDatas <> iMax then
	begin
		FMaxDatas := iMax ;
		for ShareIndex := 0 to High(FDatas) do
		begin
			if FDatas[ShareIndex].Count > FMaxDatas then
			begin
				while FDatas[ShareIndex].Count > FMaxDatas do
				begin
					Delete(ShareIndex, FDatas[ShareIndex].Count - 1) ;
				end ;
				FDatas[ShareIndex].Pack() ;
			end ;
		end ;
	end ;
	if FGraphType <> gtType then	FGraphType := gtType ;
end ;
// Data 삽입
procedure TFaShareData.AddData(ShareIndex : Integer; Value : Double);
var
	pData : TAxisData ;
begin
	if FMaxDatas = 0 then Exit ;
	if (ShareIndex >= 0) and (ShareIndex <= High(FDatas)) then
	begin
    	if (FDatas[ShareIndex].Count < FMaxDatas) then
    	begin
    		New(pData) ;
    		pData^ := Value ;
    		FDatas[ShareIndex].Add(pData) ;
    	end
    	else
    	begin
    		//if FGraphType <> gtNormal then
    		begin
    			Move(ShareIndex, 0, FDatas[ShareIndex].Count - 1) ;
    			SetData(ShareIndex, FDatas[ShareIndex].Count - 1, Value) ;

    //			FDatas[ShareIndex].Delete(0) ;
    //			FDatas[ShareIndex].Pack() ;
    //			FDatas[ShareIndex].Add(pData) ;
    		end ;
    	end ;
    end ;
end ;
// Data 삽입
procedure TFaShareData.SetData(ShareIndex : Integer; Index : Integer; Value : Double) ;
var
	pData : TAxisData ;
begin
	if (Index >= 0) and (Index < FDatas[ShareIndex].Count) then
	begin
		pData := FDatas[ShareIndex].Items[Index] ;
		pData^ := Value ;
		FDatas[ShareIndex].Items[Index] := pData;
	end ;
end ;
// Index 위치의 Data 읽기
function TFaShareData.GetData(ShareIndex : Integer; Index : Integer; var Value : Double) : Boolean ;
var
	pData : TAxisData ;
begin
	Value := 0 ;
	Result := (Index >= 0) and (Index < FDatas[ShareIndex].Count) ;
	if (Index >= 0) and (Index < FDatas[ShareIndex].Count) then
	begin
		pData := FDatas[ShareIndex].Items[Index] ;
		Value := pData^ ;
	end ;
end ;
// Data Buffer 비우기
procedure TFaShareData.Empty(ShareIndex : Integer) ;
var
	i : integer ;
begin
	if (ShareIndex >= 0) and (ShareIndex <= High(FDatas)) then
	begin
    	for i := FDatas[ShareIndex].Count - 1 downto 0 do
    	begin
    		Dispose(FDatas[ShareIndex].Items[i]) ;
    		FDatas[ShareIndex].Items[i] := nil ;
    	end ;
    	FDatas[ShareIndex].Clear ;
	end ;
end ;
// 현재 MaxIndex
function TFaShareData.GetMaxIndex(ShareIndex : Integer) : Integer ;
begin
	Result := 0 ;
	if (ShareIndex >= 0) and (ShareIndex <= High(FDatas)) then
		Result := FDatas[ShareIndex].Count ;
end ;

procedure  TFaShareData.Move(ShareIndex, CurIndex, NewIndex: Integer);
begin
	if (ShareIndex >= 0) and (ShareIndex <= High(FDatas)) then
	begin
		FDatas[ShareIndex].Move(CurIndex, NewIndex) ;
	end ;
end ;
procedure  TFaShareData.Delete(ShareIndex, Index: Integer);
begin
	if (ShareIndex >= 0) and (ShareIndex <= High(FDatas)) then
	begin
		Dispose(FDatas[ShareIndex].Items[Index]) ;
		FDatas[ShareIndex].Delete(Index) ;
	end ;
end ;

function TFaShareData.CopyTo(ShareIndex: Integer; var Value : Array of Single; Count: Integer) : Integer ;
var
	i : Integer ;
	pData : TAxisData ;
begin
	if Count = 0 then Count := High(Value) ;
	if Count > FDatas[ShareIndex].Count - 1 then Count := FDatas[ShareIndex].Count - 1 ;
	for i := 0 to Count do
	begin
		pData := FDatas[ShareIndex].Items[i] ;
		Value[i] := pData^ ;
	end ;
	Result := Count + 1 ;
end ;

function TFaShareData.CopyFrom(ShareIndex: Integer; var Value : Array of Single; Count: Integer) : Integer ;
var
	Index : Integer ;
	pData : TAxisData ;
	analog : Double ;
begin
	if Count = 0 then Count := High(Value) ;

    if (FDatas[ShareIndex].Count > (Count + 1)) then
    begin
        for Index := FDatas[ShareIndex].Count - 1 downto Count + 1 do
        begin
            Dispose(FDatas[ShareIndex].Items[Index]) ;
		    FDatas[ShareIndex].Delete(Index) ;
        end ;
    end ;

	for Index := 0 to Count do
	begin
        if FDatas[ShareIndex].Count <= Index then
        begin
    		New(pData) ;
    		pData^ := Value[Index] ;
    		FDatas[ShareIndex].Add(pData) ;

            AddData(ShareIndex, Value[Index])
        end
        else
        begin
            pData := FDatas[ShareIndex].Items[Index] ;
            pData^ := Value[Index] ;
            FDatas[ShareIndex].Items[Index] := pData;
        end ;
	end ;
	Result := Count + 1 ;
end ;

procedure TFaShareData.FilterRL(iShareIndex: Integer; iBufCount : Integer = 15) ;
var
    index, iMaxCount : Integer ;

    Data : Double ;
    aDatas : array of Double ;
    lCount: Integer ;
    lIndex, iIndex: Integer ;
begin
    iMaxCount := GetMaxIndex(iShareIndex) ;
    if iMaxCount > 0 then
    begin
        SetLength(aDatas, iBufCount) ;
        iIndex := 0 ;
        lCount := 0 ;
        for index := 0 to iMaxCount - 1 do
        begin
            GetData(iShareIndex, index, aDatas[iIndex]) ;

            Inc(iIndex) ;
            iIndex := iIndex mod iBufCount ;
            if lCount < iBufCount then Inc(lCount) ;

            Data := 0 ;
            for lIndex := 0 to lCount - 1 do Data := Data + aDatas[lIndex] ;
            Data := Data / lCount ;

            SetData(iShareIndex, index, Data) ;
        end ;
        SetLength(aDatas, 0) ;
    end ;
end ;
procedure TFaShareData.FilterXY(iSXIndex, iSYIndex : Integer) ;
var
	Index, iMaxCount : Integer ;
	dx, dy : Double ;
	Prev, Curr, Next : Double ;
begin
    iMaxCount := GetMaxIndex(iSXIndex) ;

    Index := 1 ;
    while index < iMaxCount - 2 do
    begin
        GetData(iSXIndex, index - 1, Prev) ;
        GetData(iSXIndex, index, Curr) ;
        GetData(iSXIndex, index + 1, Next) ;

        if (Next <> Prev) then
        begin
            dx := (Curr - Prev) / (Next - Prev) ;

            GetData(iSYIndex, index - 1, Prev) ;
        	GetData(iSYIndex, index, Curr) ;
            GetData(iSYIndex, index + 1, Next) ;

            dy := Next - Prev ;
            if (Next <> 0) and (dx <> 0) and  (dy <> 0) then SetData(iSYIndex, index, Prev + (dy * dx))
            else											 SetData(iSYIndex, index, (Prev + Curr + Next) / 3) ;
        end ;
        Inc(Index, 1) ;
    end ;
end ;
procedure TFaShareData.Filter(iShareIndex : Integer) ;
var
	index, iMaxCount : Integer ;
	Prev, Curr, Next : Double ;
begin
    iMaxCount := GetMaxIndex(iShareIndex) ;

    GetData(iShareIndex, 0, Curr) ;
    GetData(iShareIndex, 1, Next) ;
    SetData(iShareIndex, 0, (Curr + Next) / 2) ;
    for Index := 1 to iMaxCount - 2 do
    begin
        GetData(iShareIndex, index - 1, Prev) ;
        GetData(iShareIndex, index, Curr) ;
        GetData(iShareIndex, index + 1, Next) ;

        SetData(iShareIndex, index, (Prev + Curr + Next) / 3) ;
    end ;
    GetData(iShareIndex, iMaxCount - 2, Curr) ;
    GetData(iShareIndex, iMaxCount - 1, Next) ;
    SetData(iShareIndex, iMaxCount - 1, (Curr + Next) / 2) ;
end ;

procedure TFaShareData.Save(var fsSave : TFileStream; SaveCnt: Integer) ;
var
	CopyCount : Integer ;
	ShareIndex: Integer;
	SingleMemory : array of Single ;
begin
	CopyCount := 0 ;
//	for ShareIndex := 0 to High(FDatas) do
	for ShareIndex := 0 to SaveCnt - 1 do
	begin
		if FDatas[ShareIndex].Count > 0 then
		begin
			CopyCount := FDatas[ShareIndex].Count ;

			SetLength(SingleMemory, CopyCount) ;
			CopyCount := CopyTo(ShareIndex, SingleMemory) ;
			fsSave.Write(CopyCount, SizeOf(Integer)) ;
			if CopyCount <> 0 then
			begin
            	if fsSave.Write(SingleMemory[0], SizeOf(Single) * CopyCount) <> SizeOf(Single) * CopyCount then
				begin
					ShowMessage('Graph save error') ;
                end ;
            end ;
		end
		else
		begin
			CopyCount := 0 ;
			fsSave.Write(CopyCount, SizeOf(Integer)) ;
		end ;
		//else	Break ;
	end ;
	SetLength(SingleMemory, 0) ;
end ;
function TFaShareData.Save(var fsSave : TFileStream; ShareIndex: TShareIndex; smSave : TFaGraphSaveMode) : Boolean ;
var
	CopyCount : Integer ;
	SingleMemory : array of Single ;
begin
	case smSave of
		smNew:
			begin
				fsSave.Seek(0, soFromBeginning) ;
				fsSave.Size := 0 ;
			end ;
		smAdd: fsSave.Seek(0, soFromEnd) ;
		smCur:	;
	end ;
	SetLength(SingleMemory, FDatas[ShareIndex].Count) ;
    try
        CopyCount := CopyTo(ShareIndex, SingleMemory) ;

        Result := (CopyCount = FDatas[ShareIndex].Count) ;
        if Result then
        begin
            if fsSave.Write(CopyCount, SizeOf(CopyCount)) = SizeOf(CopyCount) then
            begin
                if CopyCount <> 0 then
                begin
                    Result := fsSave.Write(SingleMemory[0], SizeOf(Single) * CopyCount) = SizeOf(Single) * CopyCount ;
                end ;
            end ;
        end
        else
        begin
            CopyCount := 0 ;
             fsSave.Write(CopyCount, SizeOf(CopyCount)) ;
        end ;
    finally
	    SetLength(SingleMemory, 0) ;
    end ;
end ;
procedure TFaShareData.Load(var fsLoad : TFileStream; LoadCnt : Integer) ;
var
	CopyCount : Integer ;
	ShareIndex: Integer;
	SingleMemory : array of Single ;
begin
	CopyCount := 0 ;
//	for ShareIndex := 0 to High(FDatas) do
		for ShareIndex := 0 to LoadCnt - 1 do
		begin
			if fsLoad.Read(CopyCount, SizeOf(Integer)) <> SizeOf(Integer) then Break ;

			if FMaxDatas < CopyCount then	FMaxDatas := CopyCount ;
			if CopyCount <> 0 then
			begin
				try
					SetLength(SingleMemory, CopyCount) ;

					if fsLoad.Read(SingleMemory[0], SizeOf(Single) * CopyCount) <> SizeOf(Single) * CopyCount then Break ;
					CopyCount := CopyFrom(ShareIndex, SingleMemory) ;
				finally
					SetLength(SingleMemory, 0) ;
				end ;
			end ;
		end ;
end ;
procedure TFaShareData.Load(var fsLoad : TFileStream; ShareIndex: TShareIndex; lmLoad : TFaGraphLoadMode) ;
var
	CopyCount : Integer ;
	SingleMemory : array of Single ;
begin
	case lmLoad of
		lmBegin:	fsLoad.Seek(0, soFromBeginning) ;
		lmCur:      ;
		lmSkip:		;
	end ;
	if fsLoad.Read(CopyCount, SizeOf(CopyCount)) = SizeOf(CopyCount) then
    begin
        if FMaxDatas < CopyCount then FMaxDatas := CopyCount ;
        if CopyCount <> 0 then
        begin
            SetLength(SingleMemory, CopyCount) ;
            if fsLoad.Read(SingleMemory[0], SizeOf(Single) * CopyCount) = SizeOf(Single) * CopyCount then
            begin
                if lmLoad <> lmSkip then CopyFrom(ShareIndex, SingleMemory) ;
            end ;
            SetLength(SingleMemory, 0) ;
        end ;
    end ;
end ;

//------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
constructor TFaSerie.Create(Collection: TCollection);
begin
	inherited Create(Collection);
	FXAxis := -1 ;
	FYAxis := -1 ;
	FXShare := 0 ;
	FYShare := 1 ;

	FWidth  := 1 ;
	FPointWidth  := 4 ;
	FAutoPointWidth  := True ;
	FVisible := True ;
	FStyles := gsLine ;
	FPoints := gpNone ;
	FPointsFill := True ;
	FLineColor := clRed ;
	FPointColor:= clRed ;
end;
destructor TFaSerie.Destroy ;
begin
	inherited Destroy;
end;
{
function TFaSerie.Paser(aiAxis: TAxisIndexs; arrow: Boolean; var Value : String) : Boolean ;
	function IsAlign(index: Integer; arrow: Boolean) : Boolean ;
	begin
		if arrow then	// x axis
		begin
			Result := TFaSeries(GetOwner).FFaAxis.Items[index].Align in [aaTop, aaBottom, aaHoriCenter] ;
		end
		else
		begin
			Result := TFaSeries(GetOwner).FFaAxis.Items[index].Align in [aaLeft, aaRight, aaVertCenter] ;
		end ;
	end ;
var
	inBrk, outBrk, Index, Count, Data : Integer ;
	asTemp : String ;
begin
	Result := False ;
	if (Value[1] = '[') and (Value[Length(Value)] = ']') then
	begin
		inBrk  := 0 ;
		outBrk := 0 ;
		Count  := 0 ;
		SetLength(aiAxis, Count) ;
		for Index := 1 to Length(Value) do
		begin
			case Value[Index] of
				'[':
				begin
					Inc(inBrk);
					asTemp := '' ;
				end ;
				']':
				begin
					Inc(outBrk);
					if Length(asTemp) > 0then
					begin
						Data := StrToInt(asTemp) ;
						if (Data >= 0) and (Data < TFaSeries(GetOwner).FaAxisCount) then
						begin
							if IsAlign(Data, arrow) then
							begin
								Inc(Count);
								SetLength(aiAxis, Count) ;
								aiAxis[Count - 1] := Data ;
							end ;
						end ;
						asTemp := '' ;
					end ;
				end ;
				',':
				begin
					Data := StrToInt(asTemp) ;
					if (Data >= 0) and (Data < TFaSeries(GetOwner).FaAxisCount) then
					begin
						if IsAlign(Data, arrow) then
						begin
							Inc(Count);
							SetLength(aiAxis, Count) ;
							aiAxis[Count - 1] := Data ;
						end ;
					end ;
					asTemp := '' ;
				end ;
				'0'..'9':
				begin
					asTemp := asTemp + Value[Index] ;
				end ;
			end ;
		end ;
		if (inBrk = 1) and (outBrk = 1) then
		begin
			Value := '[' ;
			for index := Low(aiAxis) to High(aiAxis) do
			begin
				Value := Value + IntToStr(aiAxis[index]) ;
				if index <> High(aiAxis) then Value := Value + ',' ;
			end ;
			Value := Value + ']' ;
			Result := true ;
		end ;
	end ;
end ;
}
procedure TFaSerie.Assign(Source: TPersistent);
var
	fsSerie : TFaSerie ;
begin
	if (Source is TFaSerie) and (Source <> nil) then
	begin
		fsSerie := TFaSerie(Source) ;

		AxisX	:= fsSerie.AxisX ;
		AxisY   := fsSerie.AxisY ;
		ShareX	:= fsSerie.ShareX ;
		ShareY   := fsSerie.ShareY ;
		Styles  := fsSerie.Styles;
		Points  := fsSerie.Points;
		PointsFill  := fsSerie.PointsFill;
		PointColor := fsSerie.PointColor;
		LineColor  := fsSerie.LineColor;

		Width     :=  fsSerie.Width ;
		Visible   :=  fsSerie.Visible ;

		AutoPointWidth 	:= fsSerie.AutoPointWidth ;
		PointWidth 		:= fsSerie.PointWidth ;

		Exit;
	end;
	inherited Assign(Source);
end;

procedure TFaSerie.SetXAxis(Value : Integer) ;
begin
	if FXAxis <> Value then
	begin
		if Value in [0..TFaSeries(GetOwner).FaAxisCount] then
		begin
			if TFaSeries(GetOwner).FFaAxis.Items[Value].Align in [aaTop, aaBottom, aaHoriCenter] then
			begin
				FXAxis := Value ;
				TFaSeries(GetOwner).Update(Self) ;
			end
			else
			begin
				MessageDlg('등록된 X Axis의 Align 오류.' +#13+#13+'Align: aaTop, aaBottom, aaHoriCenter', mtError, [mbOk], 0) ;
			end ;
		end ;
	end ;
end ;
procedure TFaSerie.SetYAxis(Value : Integer) ;
begin
	if FYAxis <> Value then
	begin
		if Value in [0..TFaSeries(GetOwner).FaAxisCount] then
		begin
			if TFaSeries(GetOwner).FFaAxis.Items[Value].Align in [aaLeft, aaRight, aaVertCenter] then
			begin
				FYAxis := Value ;
				TFaSeries(GetOwner).Update(Self) ;
			end
			else
			begin
				MessageDlg('등록된 Y Axis의 Align 오류.' +#13+#13+'Align: aaLeft, aaRight, aaVertCenter', mtError, [mbOk], 0) ;
			end ;
		end ;
	end ;
end ;

procedure TFaSerie.SetWidth(Value : Integer) ;
begin
	if (Value > 0) and (FWidth <> Value) then
	begin
		FWidth := Value ;
		TFaSeries(GetOwner).Update(Self) ;
	end ;
end ;
procedure TFaSerie.SetPointWidth(Value : Integer) ;
begin
	if (Value > 0) and (FPointWidth <> Value) then
	begin
		FPointWidth := Value ;
		TFaSeries(GetOwner).Update(Self) ;
	end ;
end ;
procedure TFaSerie.SetAutoPointWidth(Value : Boolean) ;
begin
	if (FAutoPointWidth <> Value) then
	begin
		FAutoPointWidth := Value ;
		TFaSeries(GetOwner).Update(Self) ;
	end ;
end ;
procedure TFaSerie.SetVisible(Value : Boolean) ;
begin
	if (FVisible <> Value) then
	begin
		FVisible := Value ;
		TFaSeries(GetOwner).Update(Self) ;
	end ;
end ;
procedure TFaSerie.SetXShare(Value : TShareIndex) ;
begin
	if FXShare <> Value then
	begin
		FXShare := Value
	end ;
end ;
procedure TFaSerie.SetYShare(Value : TShareIndex) ;
begin
	if FYShare <> Value then
	begin
		FYShare := Value
	end ;
end ;

procedure TFaSerie.SetStyles(Value: TFaGraphStyle) ;
begin
	if FStyles <> Value then
	begin
		FStyles := Value ;
		TFaSeries(GetOwner).Update(Self) ;
	end ;
end ;
procedure TFaSerie.SetPoints(Value: TFaGraphPoint) ;
begin
	if FPoints <> Value then
	begin
		FPoints := Value ;
		TFaSeries(GetOwner).Update(Self) ;
	end ;
end ;
procedure TFaSerie.SetPointsFill(Value: Boolean) ;
begin
	if FPointsFill <> Value then
	begin
		FPointsFill := Value ;
		TFaSeries(GetOwner).Update(Self) ;
	end ;
end ;
procedure TFaSerie.SetPointColor(Value: TColor) ;
begin
	if FPointColor <> Value then
	begin
		FPointColor := Value ;
		TFaSeries(GetOwner).Update(Self) ;
	end ;
end ;
procedure TFaSerie.SetLineColor(Value: TColor) ;
begin
	if FLineColor <> Value then
	begin
		FLineColor := Value ;
		TFaSeries(GetOwner).Update(Self) ;
	end ;
end ;

procedure TFaSerie.AddData(x, y : Double) ;
begin
	if FXAxis < 0 then Exit ;
	TFaSeries(GetOwner).FFaGraph.FSdShare.AddData(FXShare, x) ;
	TFaSeries(GetOwner).FFaGraph.FSdShare.AddData(FYShare, y) ;
end ;
procedure TFaSerie.AddData(x, y : array of Double) ;
begin
	if FXAxis < 0 then Exit ;
	if High(x) >= 0 then TFaSeries(GetOwner).FFaGraph.FSdShare.AddData(FXShare, x[0]) ; ;
	if High(y) >= 0 then TFaSeries(GetOwner).FFaGraph.FSdShare.AddData(FYShare, y[0]) ; ;
end ;
procedure TFaSerie.SetData(index: Integer; x, y : Double) ;
begin
	if FXAxis < 0 then Exit ;
	TFaSeries(GetOwner).FFaGraph.FSdShare.SetData(FXShare, index, x) ;
	TFaSeries(GetOwner).FFaGraph.FSdShare.SetData(FYShare, index, y) ;
end ;
function TFaSerie.GetData(index: Integer; var x, y : Double) : Boolean ;
begin
	Result := False ;
	if FXAxis < 0 then Exit ;
	Result := 	TFaSeries(GetOwner).FFaGraph.FSdShare.GetData(FXShare, index, x) and
				TFaSeries(GetOwner).FFaGraph.FSdShare.GetData(FYShare, index, y) ;
end ;
procedure TFaSerie.Empty ;
begin
	if FXAxis < 0 then Exit ;
	TFaSeries(GetOwner).FFaGraph.FSdShare.Empty(FXShare) ;
	TFaSeries(GetOwner).FFaGraph.FSdShare.Empty(FYShare) ;
end ;
procedure TFaSerie.DrawPoint(Canvas: TCanvas; x, y, w, h: Integer; pColor, bColor: TColor) ;
var
	sPColor : TColor ;
	sBColor : TColor ;
begin
	if Points = gpNone then Exit ;

	sPColor := Canvas.Pen.Color ;
	sBColor := Canvas.Brush.Color ;
	Canvas.Pen.Color := pColor ;
	if FPointsFill then Canvas.Brush.Color := bColor ;


	case Points of
		gpCircle : 	DrawCircle(Canvas, x, y, w, h) ;
		gpTUp:      DrawTUp(Canvas, x, y, w, h) ;
		gpRect:		DrawRect(Canvas, x, y, w, h) ;
		gpCross:	DrawCross(Canvas, x, y, w, h) ;
		gpDiamond:	DrawDiamond(Canvas, x, y, w, h) ;
		gpTDown:	DrawTDown(Canvas, x, y, w, h) ;
		gpTLeft:	DrawTLeft(Canvas, x, y, w, h) ;
		gpTRight:	DrawTRight(Canvas, x, y, w, h) ;
		gpX :       DrawX(Canvas, x, y, w, h) ;
	end ;
	Canvas.Pen.Color := sPColor ;
	Canvas.Brush.Color := sBColor ;

	Canvas.MoveTo(x, y) ;
end ;

procedure TFaSerie.DrawScrollData(Canvas : TCanvas; Rect : TRect);
var
	//Index, MaxIndex, x, y, w : Integer ;
	MaxIndex, x, y, w : Integer ;
	xData, yData : Double ;
	sPWidth          : Integer ;
	sPColor, sBColor : TColor ;
	sPStyle          : TPenStyle ;
begin
	sPColor := Canvas.Pen.Color ;
	sPWidth := Canvas.Pen.Width ;
	sBColor := Canvas.Brush.Color ;
	sPStyle := Canvas.Pen.Style ;

	if FXAxis < 0 then Exit ;
	if not FVisible then Exit ;

	MaxIndex := TFaSeries(GetOwner).FFaGraph.FSdShare.GetMaxIndex(FXShare) ;
	if MaxIndex > 0 then
	begin
//		if TFaSeries(GetOwner).FFaAxis.Items[FYAxis].GetMaxIndex <> MaxIndex then Exit ;
		Canvas.Pen.Color := FLineColor ;
		Canvas.Pen.Width := FWidth ;
		//Canvas.Brush.Color := FPointColor ;

		if FAutoPointWidth then	w := Canvas.TextWidth('W') div 3
		else                    w := FPointWidth ;
		if FStyles in [gsLine, gsDot] then
		begin

			//for Index := MaxIndex - 1 downto MaxIndex - 2 do
			begin
				if GetData(MaxIndex - 1, xData, yData) then
				begin
					x := Rect.Left + TFaSeries(GetOwner).FFaAxis.GetXY(FXAxis, xData, true) ;
					y := Rect.Bottom - TFaSeries(GetOwner).FFaAxis.GetXY(FYAxis, yData, true) ;
					Canvas.MoveTo(x, y) ;
					if Points <> gpNone then DrawPoint(Canvas, x, y, w, w, FLineColor, FPointColor) ;
				end ;

				if GetData(MaxIndex - 2, xData, yData) then
				begin
					x := Rect.Left + TFaSeries(GetOwner).FFaAxis.GetXY(FXAxis, xData, true) ;
					y := Rect.Bottom - TFaSeries(GetOwner).FFaAxis.GetXY(FYAxis, yData, true) ;
					Canvas.LineTo(x, y) ;
					if Points <> gpNone then DrawPoint(Canvas, x, y, w, w, FLineColor, FPointColor) ;
				end ;
			end ;
		end
		else
		begin
			//for Index := MaxIndex - 1 downto MaxIndex - 2 do
			begin
				if GetData(MaxIndex - 1, xData, yData) then
				begin
					x := Rect.Left + TFaSeries(GetOwner).FFaAxis.GetXY(FXAxis, FXAxis, true) ;
					y := Rect.Bottom - TFaSeries(GetOwner).FFaAxis.GetXY(FYAxis, FYAxis, true) ;

					Canvas.MoveTo(x, y) ;
					if Points <> gpNone then DrawPoint(Canvas, x, y, w, w, FLineColor, FPointColor) ;
				end ;
			end ;
		end ;
	end ;
	Canvas.Pen.Width := sPWidth ;
	Canvas.Pen.Color := sPColor ;
	Canvas.Brush.Color := sBColor ;
	Canvas.Pen.Style := sPStyle ;
end ;

procedure TFaSerie.DrawViewData(Canvas : TCanvas; Rect: TRect; Start: Integer);
var
	Index, MaxIndex, x, y, w : Integer ;
	xData, yData : Double ;
	sPWidth          : Integer ;
	sPColor, sBColor : TColor ;
	sPStyle : TPenStyle ;

	dotDrawing  : Boolean ;
	dotData, dotSpace : Double ;
begin
	sPColor := Canvas.Pen.Color ;
	sPWidth := Canvas.Pen.Width ;
	sBColor := Canvas.Brush.Color ;
	sPStyle := Canvas.Pen.Style ;
	if FXAxis < 0 then Exit ;
	if not FVisible then Exit ;

	MaxIndex := TFaSeries(GetOwner).FFaGraph.FSdShare.GetMaxIndex(FXShare) ;
	if MaxIndex > 0 then
	begin
		Canvas.Pen.Color := FLineColor ;
		Canvas.Pen.Width := FWidth ;
		//Canvas.Brush.Color := FPointColor ;

		if FAutoPointWidth then	w := Canvas.TextWidth('W') div 3
		else                    w := FPointWidth ;
		if FStyles in [gsLine, gsDot] then
		begin
			if GetData(Start, xData, yData) then
			begin
				x := Rect.Left + TFaSeries(GetOwner).FFaAxis.GetXY(FXAxis, xData, true) ;
				y := Rect.Bottom - TFaSeries(GetOwner).FFaAxis.GetXY(FYAxis, yData, true) ;

				Canvas.MoveTo(x, y) ;
				DrawPoint(Canvas, x, y, w, w, FLineColor, FPointColor) ;

				dotData    := xData ;
				dotDrawing := True ;
				dotSpace := TFaSeries(GetOwner).FFaAxis.Items[FXAxis].Step / 20 ;
				for Index := Start + 1 to MaxIndex - 1 do
				begin
					if GetData(Index, xData, yData) then
					begin
						x := Rect.Left + TFaSeries(GetOwner).FFaAxis.GetXY(FXAxis, xData, true) ;
						y := Rect.Bottom - TFaSeries(GetOwner).FFaAxis.GetXY(FYAxis, yData, true) ;

						if FStyles = gsDot then
						begin
							if xData > (dotData + dotSpace) then
							begin
								dotData := xData ;
								dotDrawing := not dotDrawing ;
							end ;
						end ;
						if dotDrawing then
						begin
							Canvas.LineTo(x, y) ;
							DrawPoint(Canvas, x, y, w, w, FLineColor, FPointColor) ;
						end
						else
						begin
							Canvas.MoveTo(x, y) ;
						end ;

						if (x >= Rect.Right) then Break ;
					end ;
				end ;
			end ;
		end
		else
		begin
			for Index := Start to MaxIndex - 1 do
			begin
				if GetData(Index, xData, yData) then
				begin
					x := Rect.Left + TFaSeries(GetOwner).FFaAxis.GetXY(FXAxis, xData, true) ;
					y := Rect.Bottom - TFaSeries(GetOwner).FFaAxis.GetXY(FYAxis, yData, true) ;

					Canvas.MoveTo(x, y) ;

					DrawPoint(Canvas, x, y, w, w, FLineColor, FPointColor) ;
					if (x >= Rect.Right) then Break ;
				end ;
			end ;
		end ;
	end ;
	Canvas.Pen.Width := sPWidth ;
	Canvas.Pen.Color := sPColor ;
	Canvas.Brush.Color := sBColor ;
	Canvas.Pen.Style := sPStyle ;
end ;
procedure TFaSerie.DrawData(Canvas : TCanvas; Rect: TRect);
var
	Index, MaxIndex, x, y, w : Integer ;
	xData, yData : Double ;
	sPWidth          : Integer ;
	sPColor, sBColor : TColor ;
	sPStyle : TPenStyle ;
	iStartIndex, iStopIndex : Integer ;

	dotDrawing  : Boolean ;
	dotData, dotSpace : Double ;
begin
	sPColor := Canvas.Pen.Color ;
	sPWidth := Canvas.Pen.Width ;
	sBColor := Canvas.Brush.Color ;
	sPStyle := Canvas.Pen.Style ;

	if FXAxis < 0 then Exit ;
	if not FVisible then Exit ;

	//MaxIndex := TFaSeries(GetOwner).FFaGraph.FSdShare.GetMaxIndex(FXShare) ;
	MaxIndex := Min(TFaSeries(GetOwner).FFaGraph.FSdShare.GetMaxIndex(FXShare), TFaSeries(GetOwner).FFaGraph.FSdShare.GetMaxIndex(FYShare)) ;
	if MaxIndex > 0 then
	begin
		Canvas.Pen.Color := FLineColor ;
		Canvas.Pen.Width := FWidth ;
		//Canvas.Brush.Color := FPointColor ;

		if FAutoPointWidth then	w := Canvas.TextWidth('W') div 3
		else                    w := FPointWidth ;

		iStartIndex := -1 ;
		iStopIndex := MaxIndex - 1 ;
		// Start Index
		for Index := MaxIndex - 1 downto 0 do
		begin
			if GetData(Index, xData, yData) then
			begin
				x := Rect.Left + TFaSeries(GetOwner).FFaAxis.GetXY(FXAxis, xData, true) ;
				if (x >= Rect.Left) and (x <= Rect.Right) then
				begin
                    //======
                    // 2005.07.20 PATCH
                    // 그래프 영역을 벗어난 데이터로 인해 WindowsME에서 특정영역이 특정색깔로 Fill 되는 현상 발생
                    //
					//  if Index = MaxIndex - 1 then iStartIndex := Index
					//  else                         iStartIndex := Index + 1 ;
                    //===
                    iStartIndex := Index ;
					Break ;
				end ;
			end ;
		end ;
		// Start Index
		for Index := iStartIndex downto 0 do
		begin
			if GetData(Index, xData, yData) then
			begin
				x := Rect.Left + TFaSeries(GetOwner).FFaAxis.GetXY(FXAxis, xData, true) ;
				if (x >= Rect.Left) and (x <= Rect.Right) then
				begin
                    //======
                    // 2005.07.20 PATCH
                    // 그래프 영역을 벗어난 데이터로 인해 WindowsME에서 특정영역이 특정색깔로 Fill 되는 현상 발생
                    //
					//  if index = 0 then 	iStopIndex := 0
					//  else				iStopIndex := Index - 1 ;
                    //===
                    iStopIndex := Index ;
				end ;
			end ;
		end ;
		if iStartIndex >= iStopIndex then
		begin
			if FStyles in [gsLine, gsDot] then
			begin
				if GetData(iStartIndex, xData, yData) then
				begin
					x := Rect.Left + TFaSeries(GetOwner).FFaAxis.GetXY(FXAxis, xData, true) ;
					y := Rect.Bottom - TFaSeries(GetOwner).FFaAxis.GetXY(FYAxis, yData, true) ;

					Canvas.MoveTo(x, y) ;
					DrawPoint(Canvas, x, y, w, w, FLineColor, FPointColor) ;

					dotData    := xData ;
					dotDrawing := True ;
					dotSpace := TFaSeries(GetOwner).FFaAxis.Items[FXAxis].Step / 20 ;
					for Index := iStartIndex downto iStopIndex do
					begin
						if GetData(Index, xData, yData) then
						begin
							x := Rect.Left + TFaSeries(GetOwner).FFaAxis.GetXY(FXAxis, xData, true) ;
							y := Rect.Bottom - TFaSeries(GetOwner).FFaAxis.GetXY(FYAxis, yData, true) ;

							if FStyles = gsDot then
							begin
								if xData < (dotData - dotSpace) then
								begin
									dotData := xData ;
									dotDrawing := not dotDrawing ;
								end ;
							end ;
							if dotDrawing then
							begin
								Canvas.LineTo(x, y) ;
								DrawPoint(Canvas, x, y, w, w, FLineColor, FPointColor) ;
							end
							else
							begin
								Canvas.MoveTo(x, y) ;
							end ;
						end ;
					end ;
				end ;
			end
			else
			begin
				for Index := iStartIndex downto iStopIndex do
				begin
					if GetData(Index, xData, yData) then
					begin
						x := Rect.Left + TFaSeries(GetOwner).FFaAxis.GetXY(FXAxis, xData, true) ;
						y := Rect.Bottom - TFaSeries(GetOwner).FFaAxis.GetXY(FYAxis, yData, true) ;
						Canvas.MoveTo(x, y) ;
						DrawPoint(Canvas, x, y, w, w, FLineColor, FPointColor) ;
					end ;
				end ;
			end ;
		end ;
	end ;
	Canvas.Pen.Color := sPColor ;
	Canvas.Pen.Width := sPWidth ;
	Canvas.Brush.Color := sBColor ;
	Canvas.Pen.Style := sPStyle ;
end ;
//
function TFaSerie.FindX(var xFind : Double) : Integer ;
var
	Index, MaxIndex: Integer ;
	xCurr, xNext : Double ;
begin
	Result := -1 ;
	if FXAxis < 0 then Exit ;

	MaxIndex := TFaSeries(GetOwner).FFaGraph.FSdShare.GetMaxIndex(FXShare) ;
	if MaxIndex > 0 then
	begin
		TFaSeries(GetOwner).FFaGraph.FSdShare.GetData(FXShare, 0, xCurr) ;
		for Index := 1 to MaxIndex - 2 do
		begin
			TFaSeries(GetOwner).FFaGraph.FSdShare.GetData(FXShare, index, xNext) ;
			if (xCurr >= xFind) and (xFind <= xNext) or
			   (xNext >= xFind) and (xFind <= xCurr) then
			begin
				xFind := xCurr ;
				Result := Index - 1 ;
				Break ;
			end ;
			xCurr := xNext ;
		end ;
	end ;
end ;
function TFaSerie.FindY(var yFind : Double) : Integer ;
var
	Index, MaxIndex: Integer ;
	yCurr, yNext : Double ;
begin
	Result := -1 ;
	if FYAxis < 0 then Exit ;

	MaxIndex := TFaSeries(GetOwner).FFaGraph.FSdShare.GetMaxIndex(FYShare) ;
	if MaxIndex > 0 then
	begin
		TFaSeries(GetOwner).FFaGraph.FSdShare.GetData(FYShare, 0, yCurr) ;
		for Index := 1 to MaxIndex - 2 do
		begin
			TFaSeries(GetOwner).FFaGraph.FSdShare.GetData(FYShare, index, yNext) ;
			if (yCurr >= yFind) and (yFind <= yNext) or
			   (yNext >= yFind) and (yFind <= yCurr) then
			begin
				yFind := yCurr ;
				Result := Index - 1 ;
				Break ;
			end ;
			yCurr := yNext ;
		end ;
	end ;
end ;
//
procedure TFaSerie.DrawLabel(Canvas : TCanvas; Rect: TRect; x, y : Double; asText: String; Color: TColor) ;
var
	sFColor : TColor ;

	xPos, yPos : Integer ;
begin
	xPos := Rect.Left + TFaSeries(GetOwner).FFaAxis.GetXY(FXAxis, x, true) ;
	yPos := Rect.Bottom - TFaSeries(GetOwner).FFaAxis.GetXY(FYAxis, y, true) ;

	sFColor := Canvas.Font.Color ;
	Canvas.Font.Color := Color ;

	SetBkMode(Canvas.Handle, TRANSPARENT) ;
	TextOutCenter(Canvas, xPos, yPos, asText) ;
	SetBkMode(Canvas.Handle, OPAQUE) ;

	Canvas.Font.Color := sFColor ;
end ;
{
procedure TFaSerie.GetXY(Rect: TRect; x, y : Double; var xPos, yPos :Integer) ;
begin
	xPos := Rect.Left + TFaSeries(GetOwner).FFaAxis.GetXY(FXAxis, x) ;
	yPos := Rect.Bottom - TFaSeries(GetOwner).FFaAxis.GetXY(FYAxis, y) ;
end ;
}
//------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
constructor TFaSeries.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TFaSerie);
end;
destructor TFaSeries.Destroy ;
begin
	inherited Destroy;
end;
function TFaSeries.GetFaAxisCount : Integer ;
begin
	Result := FFaAxis.Count ;
end ;
function TFaSeries.Add: TFaSerie;
begin
	Result := TFaSerie(inherited Add);
end;
function TFaSeries.GetItem(Index: Integer) : TFaSerie;
begin
	Result := TFaSerie(inherited Items[Index]);
end;
procedure TFaSeries.SetItem(Index: Integer; Value: TFaSerie);
begin
	inherited SetItem(Index, TCollectionItem(Value));
end ;
procedure TFaSeries.Update(Item: TCollectionItem) ;
begin
	if FFaGraph <> nil then FFaGraph.Update ;
	(*
	if FFaGraph.FUpdateCount = 0 then
	begin
//		FFaGraph.Invalidate ;
		FFaGraph.Draw ;
	end ;
	*)
end ;
procedure TFaSeries.DrawScrollData(Canvas : TCanvas; Rect: TRect; siIndex : array of Integer);
var
	Index : Integer ;
begin
	for Index := Low(siIndex) to High(siIndex) do
	begin
		Items[siIndex[Index]].DrawScrollData(Canvas, Rect);
	end ;
end ;
procedure TFaSeries.DrawScrollData(Canvas : TCanvas; Rect: TRect);
var
	Index : Integer ;
begin
	for Index := 0 to Count - 1 do
	begin
		Items[Index].DrawScrollData(Canvas, Rect);
	end ;
end ;
procedure TFaSeries.DrawData(Canvas : TCanvas; Rect: TRect);
var
	Index : Integer ;
begin
	for Index := 0 to Count - 1 do
	begin
		Items[Index].DrawData(Canvas, Rect);
	end ;
end ;
procedure TFaSeries.DrawViewData(Canvas : TCanvas; Rect: TRect; Start: Integer);
var
	Index : Integer ;
begin
	for Index := 0 to Count - 1 do
	begin
		Items[Index].DrawViewData(Canvas, Rect, Start);
	end ;
end ;
procedure TFaSeries.Empty;
var
	Index : Integer ;
begin
	for Index := 0 to Count - 1 do
	begin
		Items[Index].Empty ;
	end ;
end ;

//------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
constructor TFaGraphEx.Create(AOwner: TComponent);
begin
	inherited Create(AOwner);

//    FVersion := TFaGraphVersion ;

	FSdShare := TFaShareData.Create ;

	Width := 200 ;
	Height := 200 ;

	Canvas.Font.Assign(Font) ;
    //Canvas.CopyMode := cmSrcAnd ;

	FFaAxis   := TFaAxis.Create(Self);
	FFaSeries := TFaSeries.Create(Self);

	FFaAxis.FFaGraph   := Self ;
	FFaSeries.FFaAxis  := FFaAxis ;
	FFaSeries.FFaGraph := Self ;

	FBorder := TBitmap.Create ;
    //FBorder.PixelFormat := pf8bit ; // 256 color only

	FSpace  := TFaGraphSpace.Create ;
	with FSpace do
	begin
		Left := 8 ;
		Top := 8 ;
		Right := 8 ;
		Bottom := 8 ;
	end ;
	FBoardColor := clWhite ;
	FGridColor := clSilver ;
	FGridDraw  := [ggVert, ggHori] ;
	FGridDrawSide  := [gsSide_1, gsSide_2, gsSide_3, gsSide_4] ;
	FViewCrossBarDraw  := [ggVert, ggHori] ;
	FGridDrawSub  := false ;
	FGRidStyle := psSolid ;
	FOutnerFrame := true ;
    FOutnerFrameColor := clBlack ;
	FHRgn 	   := 0 ;
	FMaxDatas := 0 ;
	FViewStart := 0 ;

    if Assigned(FBorder) then FBorder.Canvas.Brush.Color := FBoardColor ;

	//==================
	// DRAG 기능
	//==================
	FZoomMode := False ;
	FZoomSeries := -1 ;
	FDragMode := dmPush ;

	FViewCrossBar := false ;
	FViewCrossBarDraw  := [ggVert, ggHori] ;
	FViewCrossStatus := 0 ;


    FUserPreview    := False ;
    FLock           := False ;

    //======
    // 2007.11.01
    //===
    FUpdateDelayTime    := 0.05 ;        // 50ms 
    FUpdateDelayEnabled := False ;
    FCUpdateDelayTime   := TTimeCount.Create() ;
end;

destructor TFaGraphEx.Destroy;
begin
	if FHRgn > 0 then DeleteObject(FHRgn) ;
//	if FDragAxisX <> nil then FDragAxisX.Destroy ;
//	if FDragAxisY <> nil then FDragAxisY.Destroy ;

	FreeAndNil(FSpace) ;
	FreeAndNil(FFaAxis) ;
	FreeAndNil(FFaSeries) ;
	FreeAndNil(FBorder) ;

	FreeAndNil(FSdShare) ;
    FreeAndNil(FCUpdateDelayTime) ;

	inherited Destroy;
end;

procedure  TFaGraphEx.Save(var fsSave : TFileStream; SaveCnt : Integer) ;
begin
	if (fsSave <> nil) then
	begin
		FSdShare.Save(fsSave, SaveCnt) ;
	end ;
end ;
procedure  TFaGraphEx.Save(var fsSave : TFileStream; iIndex : TShareIndex; smSave : TFaGraphSaveMode) ;
begin
	if (fsSave <> nil) then
	begin
		FSdShare.Save(fsSave, iIndex, smSave) ;
	end ;
end ;
procedure  TFaGraphEx.Load(var fsLoad : TFileStream; LoadCnt: Integer) ;
begin
	if (fsLoad <> nil) then
	begin
		FSdShare.Load(fsLoad, LoadCnt) ;
	end ;
end ;
procedure  TFaGraphEx.Load(var fsLoad : TFileStream; iIndex : TShareIndex; lmLoad : TFaGraphLoadMode) ;
begin
	if (fsLoad <> nil) then
	begin
		FSdShare.Load(fsLoad, iIndex, lmLoad) ;
	end ;
end ;

function  TFaGraphEx.GetBoardRect : TRect ;
begin
	Result := FRect ;
end ;
procedure TFaGraphEx.SetBoardRect(Rect : TRect);
begin
	FRect := Rect ;
end ;

procedure TFaGraphEx.Empty ;
var
	index : Integer ;
begin
	FViewStart := 0 ;
	BeginUpdate() ;
	with FFaSeries do
	begin
		for index := 0 to Count - 1 do	Items[index].Empty ;
	end ;
	EndUpdate() ;
end ;
procedure TFaGraphEx.Empty(SeriesIndex : Integer) ;
begin
	FViewStart := 0 ;
	BeginUpdate() ;
	with FFaSeries do
	begin
		if (SeriesIndex >= 0) and (SeriesIndex < Count) then Items[SeriesIndex].Empty ;
	end ;
	EndUpdate() ;
end ;
procedure TFaGraphEx.AddData(siIndex: array of Integer; x, y : array of Double) ;
var
	n     : Integer ;
	xPos  : Integer ;
	cRect : TRect ;

	sPWidth          : Integer ;
	sPColor, sBColor : TColor ;
	sPStyle : TPenStyle ;
begin
	sPColor := Canvas.Pen.Color ;
	sPWidth := Canvas.Pen.Width ;
	sBColor := Canvas.Brush.Color ;
	sPStyle := Canvas.Pen.Style ;
	with FFaSeries do
	begin
		if High(siIndex) >= Count then Exit ;
		for n := 0 to High(siIndex) do
		begin
			if (n <= High(x)) and (n <= High(y)) then
			begin
				Items[siIndex[n]].AddData([x[n]], [y[n]])
			end
			else
			begin
				if n <= High(x) then
				begin
					Items[siIndex[n]].AddData([x[n]], []) ;
				end
				else
				begin
					if n <= High(y) then
					begin
						Items[siIndex[n]].AddData([], [y[n]]) ;
					end ;
				end ;
			end
		end ;

        // FLock 사용여부 확인
		if (FUpdateCount <> 0) or Printer.Printing or FUserPreview or FLock then Exit ;
        if (FBorder.Width = 0) or (FBorder.Height = 0) then Exit ;
        if not Self.Visible then Exit ;

		if FGraphType in [gtScroll, gtStepScroll, gtAutoScroll] then
		begin
			for n := 0 to High(siIndex) do
			begin
				if n <= High(x) then
				begin
					cRect := Bounds(0, 0, FBorder.Width, FBorder.Height) ;
					xPos := FFaAxis.GetXY(Items[n].FXAxis, x[n], true) ;
					if xPos >= cRect.Right then
					begin
						if FGraphType = gtAutoScroll then
						begin
							FFaAxis.Items[Items[n].FXAxis].AddScroll(x[n], FGraphType) ;
                            FFaAxis.DrawLabel(Items[n].FXAxis) ;
                            
                            FBorder.Canvas.FillRect(cRect) ;
    						if Assigned(FOnBeforePaint) then FOnBeforePaint(Self);
                            DrawGrid(FBorder.Canvas, cRect) ;
                            if Assigned(FOnScroll) then FOnScroll(Self, cRect) ;
							Break ;
						end
						else
						if FGraphType = gtScroll then
						begin
							FFaAxis.Items[Items[n].FXAxis].AddScroll(x[n], FGraphType) ;
							xPos := xPos - FFaAxis.GetXY(Items[n].FXAxis, x[n], true) ;

//							if not Printer.Printing then
							begin
								FFaAxis.DrawLabel(Items[n].FXAxis) ;
								FBorder.Canvas.Brush.Color := FBoardColor ;
								if ScrollDC(FBorder.Canvas.Handle, -(xPos), 0, cRect, cRect, 0, PRECT(nil)) then
								begin
									cRect.Left := cRect.Right - xPos ;

									FBorder.Canvas.FillRect(cRect) ;
    								if Assigned(FOnBeforePaint) then FOnBeforePaint(Self);
									DrawGrid(FBorder.Canvas, cRect) ;
									if Assigned(FOnScroll) then FOnScroll(Self, cRect) ;
								end ;
							end ;
						end
						else
						begin
							FFaAxis.Items[Items[n].FXAxis].AddScroll ;
							xPos := FFaAxis.GetXY(Items[n].FXAxis, FFaAxis.Items[Items[n].FXAxis].Min + FFaAxis.Items[Items[n].FXAxis].Step) ;
//							if not Printer.Printing then
							begin
								FFaAxis.DrawLabel(Items[n].FXAxis) ;
								FBorder.Canvas.Brush.Color := FBoardColor ;
								if ScrollDC(FBorder.Canvas.Handle, -(xPos), 0, cRect, cRect, 0, PRECT(nil)) then
								begin
									cRect.Left := cRect.Right - xPos ;
									FBorder.Canvas.FillRect(cRect) ;
    								if Assigned(FOnBeforePaint) then FOnBeforePaint(Self);
									DrawGrid(FBorder.Canvas, cRect) ;
									if Assigned(FOnScroll) then FOnScroll(Self, cRect) ;
								end ;
							end ;
						end ;
						Break ;
					end ;
				end ;
			end ;
		end ;
	end ;
	Canvas.Pen.Color := sPColor ;
	Canvas.Pen.Width := sPWidth ;
	Canvas.Brush.Color := sBColor ;
	Canvas.Pen.Style := sPStyle ;

	//	if not Printer.Printing then DrawData ;
    // FLock 사용여부 확인
	if not Printer.Printing and not FUserPreview and not FLock then
	begin
		DrawData(siIndex) ;
	end ;
end ;


procedure TFaGraphEx.SetUpdateDelayEnabled(Value : Boolean) ;
begin
	if FUpdateDelayEnabled <> Value then
	begin
	   FUpdateDelayEnabled := Value ;
	   if FUpdateDelayEnabled then FCUpdateDelayTime.START() ;
    end ;
end ;

procedure TFaGraphEx.SetGridDraw(Value : TFaGraphGrids) ;
begin
	if FGridDraw <> Value then
	begin
	   FGridDraw := Value ;
	   if FUpdateCount = 0 then Invalidate ;
	end ;
end ;
procedure TFaGraphEx.SetGridDrawSide(Value : TFaGraphSides) ;
begin
	if FGridDrawSide <> Value then
	begin
	   FGridDrawSide := Value ;
	   if FUpdateCount = 0 then Invalidate ;
	end ;
end ;
procedure TFaGraphEx.SetGridDrawSub(Value : Boolean) ;
begin
	if FGridDrawSub <> Value then
	begin
	   FGridDrawSub := Value ;
	   if FUpdateCount = 0 then Invalidate ;
	end ;
end ;
procedure TFaGraphEx.SetGridColor(Value : TColor) ;
begin
	if FGridColor <> Value then
	begin
	   FGridColor := Value ;
	   if FUpdateCount = 0 then Invalidate ;
	end ;
end ;
procedure TFaGraphEx.SetGridStyle(Value : TPenStyle) ;
begin
	if FGridStyle <> Value then
	begin
	   FGridStyle := Value ;
	   if FUpdateCount = 0 then Invalidate ;
	end ;
end ;
procedure TFaGraphEx.SetBoardColor(Value : TColor) ;
begin
	if FBoardColor <> Value then
	begin
	   FBoardColor := Value ;
       if Assigned(FBorder) then FBorder.Canvas.Brush.Color := FBoardColor ;
	   if FUpdateCount = 0 then Invalidate ;
	end ;
end ;

procedure TFaGraphEx.SetMaxDatas(Value : Integer) ;
begin
	if (Value >= 0) and (FMaxDatas <> Value) then
	begin
		FMaxDatas := Value ;
		FFaAxis.FMaxDatas := FMaxDatas ;
		FSdShare.SetValue(FMaxDatas, FGraphType) ;
		if FUpdateCount = 0 then Invalidate ;
	end ;
end ;
procedure TFaGraphEx.SetGraphType(Value : TGraphType) ;
begin
	if FGraphType <> Value then
	begin
	   FGraphType := Value ;
	   FSdShare.SetValue(FMaxDatas, FGraphType) ;
	   if FUpdateCount = 0 then Invalidate ;
	end ;
end ;
procedure TFaGraphEx.SetOutnerFrame(Value : Boolean) ;
begin
	if FOutnerFrame <> Value then
	begin
	   FOutnerFrame := Value ;
	   if FUpdateCount = 0 then Invalidate ;
	end ;
end ;
procedure TFaGraphEx.SetOutnerFrameColor(Value : TColor) ;
begin
	if FOutnerFrameColor <> Value then
	begin
	   FOutnerFrameColor := Value ;
	   if FUpdateCount = 0 then Invalidate ;
	end ;
end ;
procedure TFaGraphEx.SetSpace(Value : TFaGraphSpace) ;
begin
	if FSpace <> Value then
	begin
	   FSpace := Value ;
	   if FUpdateCount = 0 then Invalidate ;
	end ;
end ;
procedure TFaGraphEx.SetZoomMode(Value : Boolean) ;
begin
	if FZoomMode <> Value then
	begin
	   FZoomMode := Value ;
	   if FZoomMode and (FFaSeries.Count > 0) and (FZoomSeries < 0) then ZoomSerie := 0 ;
	end ;
end ;
procedure TFaGraphEx.SetViewCrossBar(Value : Boolean) ;
begin
	if FViewCrossBar <> Value then
	begin
	   FViewCrossBar := Value ;
	   if FViewCrossBar then FViewCrossStatus := 0 ;
	   if (FFaSeries.Count > 0) and (FZoomSeries < 0) then ZoomSerie := 0 ;
	   if FUpdateCount = 0 then Invalidate ;
	end ;
end ;
procedure TFaGraphEx.SetViewCrossBarDraw(Value : TFaGraphGrids) ;
begin
	if FViewCrossBarDraw <> Value then
	begin
	   FViewCrossBarDraw := Value ;
	   if FUpdateCount = 0 then Invalidate ;
	end ;
end ;

procedure TFaGraphEx.SetZoomSeries(Value : Integer) ;
begin
	if (FZoomSeries <> Value) then
	begin
		if (FFaSeries.Count > 0) then
		begin
			if (Value >= 0) and (Value < FFaSeries.Count) then
			begin
				FZoomSeries := Value ;
			end
			else
			begin
				MessageDlg('Range: 0 to MAX SERIES COUNT', mtError, [mbOK], 0) ;
			end ;
		end
		else
		begin
			MessageDlg('EMPTY SERIES', mtError, [mbOK], 0) ;
		end ;
	end ;
end ;
procedure TFaGraphEx.SetVersion(const Value : String) ;
begin
	{
	if (TFaGraphVersion <> Value) then
	begin
    	MessageDlg('perporty Version is read-only', mtError, [mbOK], 0) ;
	end ;
    }
    ;
end ;
//============================================
//
//=============================================
procedure TFaGraphEx.DrawGrid(ggGrid: TFaGraphGrid; Value: array of Double; Rect: TRect; clColor : TColor; gsStyle : TPenStyle);
begin
	DrawGrid(GetDefaultXAxis, GetDefaultYAxis, Rect, ggGrid, Value, clColor, gsStyle);
end ;
procedure TFaGraphEx.DrawGrid(xAxis, yAxis : integer; Rect: TRect; ggGrid: TFaGraphGrid; Value: array of Double; clColor : TColor; gsStyle : TPenStyle);
var
	index 		 : Integer ;
	x, y   		 : Integer ;
	sPColor		 : TColor ;
	sPStyle      : TPenStyle ;

	Canvas 		: TCanvas ;
begin
	if Printer.Printing     then Canvas := Printer.Canvas
    else if FUserPreview    then Canvas := FUserCanvas
	else					     Canvas := FBorder.Canvas ;
//	with FBorder do
	begin
		sPColor := Canvas.Pen.Color ;
		sPStyle := Canvas.Pen.Style ;

		Canvas.Pen.Color := clColor ;
		Canvas.Pen.Style := gsStyle ;
		case ggGrid of
			ggVert:
			begin
				// Vertcal Line
				if yAxis >= 0 then
				begin
					for Index := 0 to High(Value) do
					begin
						x := Rect.Left + FFaAxis.GetXY(xAxis, Value[Index]) ;
						DrawVert(Canvas, clColor, x, Rect.Top, Rect.Bottom) ;
					end ;
				end ;
			end ;
			ggHori:
			begin
				// Horizontals Line
				if xAxis >= 0 then
				begin
					for Index := 0 to High(Value) do
					begin
						y := Rect.Bottom - FFaAxis.GetXY(yAxis, Value[Index]) - 1;
						DrawHori(Canvas, clColor, Rect.Left, y, Rect.Right) ;
					end ;
				end ;
			end ;
		end ;
		Canvas.Pen.Style := sPStyle ;
		Canvas.Pen.Color := sPColor ;
	end ;
end ;

procedure TFaGraphEx.DrawVertLine(xAxis, yAxis : integer; Rect: TRect; xData, yStart, yStop : Double; clColor : TColor; gsStyle : TPenStyle);
var
	x, y1, y2    : Integer ;
	sPColor		 : TColor ;
	sPStyle      : TPenStyle ;

	Canvas 		: TCanvas ;
begin
	if Printer.Printing     then Canvas := Printer.Canvas
    else if FUserPreview    then Canvas := FUserCanvas
	else					     Canvas := FBorder.Canvas ;
//	with FBorder do
	begin
		sPColor := Canvas.Pen.Color ;
		sPStyle := Canvas.Pen.Style ;

		Canvas.Pen.Color := clColor ;
		Canvas.Pen.Style := gsStyle ;

		x := Rect.Left + FFaAxis.GetXY(xAxis, xData, true) ;
		y1 := Rect.Bottom - FFaAxis.GetXY(yAxis, yStart, true) ;
		y2 := Rect.Bottom - FFaAxis.GetXY(yAxis, yStop, true) ;
		DrawVert(Canvas, clColor, x, y1, y2) ;

		Canvas.Pen.Style := sPStyle ;
		Canvas.Pen.Color := sPColor ;
	end ;
end ;
procedure TFaGraphEx.DrawHoriLine(xAxis, yAxis : integer; Rect: TRect; xStart, xStop, yData : Double; clColor : TColor; gsStyle : TPenStyle);
var
	x1, x2, y    : Integer ;
	sPColor		 : TColor ;
	sPStyle      : TPenStyle ;

	Canvas 		: TCanvas ;
begin
	if Printer.Printing     then Canvas := Printer.Canvas
    else if FUserPreview    then Canvas := FUserCanvas
	else					     Canvas := FBorder.Canvas ;
//	with FBorder do
	begin
		sPColor := Canvas.Pen.Color ;
		sPStyle := Canvas.Pen.Style ;

		Canvas.Pen.Color := clColor ;
		Canvas.Pen.Style := gsStyle ;

		x1 := Rect.Left + FFaAxis.GetXY(xAxis, xStart, true) ;
		x2 := Rect.Left + FFaAxis.GetXY(xAxis, xStop, true) ;
		y := Rect.Bottom - FFaAxis.GetXY(yAxis, yData, true) - 1;
		DrawHori(Canvas, clColor, x1, y, x2) ;

		Canvas.Pen.Style := sPStyle ;
		Canvas.Pen.Color := sPColor ;
	end ;
end ;

procedure TFaGraphEx.DrawGrid(Canvas : TCanvas; Rect: TRect);
var
	xAxis, yAxis : Integer ;
	x, y   		 : Integer ;
	xyData       : Double ;
	sPColor		 : TColor ;
	sPStyle      : TPenStyle ;

	subTick		: Double ;
    zeroData 	: Double ;
begin
	xAxis := GetDefaultXAxis ;
	yAxis := GetDefaultYAxis ;

	if (xAxis >= 0) and (yAxis >= 0) then
	begin
		sPColor := Canvas.Pen.Color ;
		sPStyle := Canvas.Pen.Style ;

		Canvas.Pen.Style := FGridStyle ;
		if ggVert in FGridDraw then
		begin
			// Vertcal Line
			with FFaAxis.Items[xAxis] do
			begin
				if ShowSubTick and GridDrawSub then subTick := Step / SubTickCount
				else                				subTick := Step ;

                if subTick > 0 then
                begin
                    if FFaAxis.Items[xAxis].Align = aaHoriCenter then
                    begin
                        zeroData := GetMin() ; //+ (GetMax() - GetMin()) / 2 ;
                        while zeroData < (GetMax() - GetMin()) / 2 do zeroData := zeroData + subtick ;
                        if gsSide_1 in FGridDrawSide then
                        begin
                            xyData := zeroData ; //+ subTick ;
                            y := Rect.Bottom - FFaAxis.GetXY(yAxis, zeroData) - 1;
                            while xyData < GetMax() - (subTick / 2) do
                            begin
                                x := Rect.Left + FFaAxis.GetXY(xAxis, xyData) ;
                                DrawVert(Canvas, FGridColor, x, Rect.Top, y) ;
                                xyData := xyData + subTick ;
                            end ;
                        end ;
                        if gsSide_2 in FGridDrawSide then
                        begin
                            xyData := zeroData ; //+ subTick ;
                            y := Rect.Bottom - FFaAxis.GetXY(yAxis, zeroData) - 1;
                            while xyData < GetMax() - (subTick / 2) do
                            begin
                                x := Rect.Left + FFaAxis.GetXY(xAxis, xyData) ;
                                DrawVert(Canvas, FGridColor, x, y, Rect.Bottom) ;
                                xyData := xyData + subTick ;
                            end ;
                        end ;
                        if gsSide_3 in FGridDrawSide then
                        begin
                            xyData := GetMin() + subTick ;
                            y := Rect.Bottom - FFaAxis.GetXY(yAxis, zeroData) - 1;
                            while xyData < zeroData {- (subTick / 2) }do
                            begin
                                x := Rect.Left + FFaAxis.GetXY(xAxis, xyData) ;
                                DrawVert(Canvas, FGridColor, x, y, Rect.Bottom) ;
                                xyData := xyData + subTick ;
                            end ;
                        end ;
                        if gsSide_4 in FGridDrawSide then
                        begin
                            xyData := GetMin() + subTick ;
                            y := Rect.Bottom - FFaAxis.GetXY(yAxis, zeroData) - 1;
                            while xyData < zeroData {- (subTick / 2) }do
                            begin
                                x := Rect.Left + FFaAxis.GetXY(xAxis, xyData) ;
                                DrawVert(Canvas, FGridColor, x, Rect.Top, y) ;
                                xyData := xyData + subTick ;
                            end ;
                        end ;
                    end
                    else
                    begin
                        xyData := GetMin() + subTick ;
                        while xyData < GetMax() - (subTick / 2) do
                        begin
                            x := Rect.Left + FFaAxis.GetXY(xAxis, xyData) ;
                            DrawVert(Canvas, FGridColor, x, Rect.Top, Rect.Bottom) ;
                            xyData := xyData + subTick ;
                        end ;
                    end ;
                end ;
			end ;
		end ;
		if ggHori in FGridDraw then
		begin
			// Horizontals Line
			with FFaAxis.Items[yAxis] do
			begin
				if ShowSubTick and GridDrawSub then subTick := Step / SubTickCount
				else                				subTick := Step ;

                if subTick > 0 then
                begin
                    zeroData := GetMin() ; //+ (GetMax() - GetMin()) / 2 ;
                    while zeroData < (GetMax() - GetMin()) / 2 do zeroData := zeroData + subTick ;
                    if FFaAxis.Items[yAxis].Align = aaVertCenter then
                    begin
                        if gsSide_1 in FGridDrawSide then
                        begin
                            xyData := zeroData ; //+ subTick ;
                            x := Rect.Left + FFaAxis.GetXY(xAxis, zeroData) ;
                            while xyData < GetMax() - (subTick / 2) do
                            begin
                                y := Rect.Bottom - FFaAxis.GetXY(yAxis, xyData) - 1;
                                DrawHori(Canvas, FGridColor, x, y, Rect.Right) ;
                                xyData := xyData + subTick ;
                            end ;
                        end ;
                        if gsSide_2 in FGridDrawSide then
                        begin
                            xyData := GetMin() + subTick ;
                            x := Rect.Left + FFaAxis.GetXY(xAxis, zeroData) ;
                            while xyData < zeroData {- (subTick / 2)} do
                            begin
                                y := Rect.Bottom - FFaAxis.GetXY(yAxis, xyData) - 1;
                                DrawHori(Canvas, FGridColor, x, y, Rect.Right) ;
                                xyData := xyData + subTick ;
                            end ;
                        end ;
                        if gsSide_3 in FGridDrawSide then
                        begin
                            xyData := GetMin() + subTick ;
                            x := Rect.Left + FFaAxis.GetXY(xAxis, zeroData) ;
                            while xyData < zeroData {- (subTick / 2)} do
                            begin
                                y := Rect.Bottom - FFaAxis.GetXY(yAxis, xyData) - 1;
                                DrawHori(Canvas, FGridColor, Rect.Left, y, x) ;
                                xyData := xyData + subTick ;
                            end ;
                        end ;
                        if gsSide_4 in FGridDrawSide then
                        begin
                            xyData := zeroData ; //+ subTick ;
                            x := Rect.Left + FFaAxis.GetXY(xAxis, zeroData) ;
                            while xyData < GetMax() - (subTick / 2) do
                            begin
                                y := Rect.Bottom - FFaAxis.GetXY(yAxis, xyData) - 1;
                                DrawHori(Canvas, FGridColor, Rect.Left, y, x) ;
                                xyData := xyData + subTick ;
                            end ;
                        end ;
                    end
                    else
                    begin
                        xyData := GetMin() + subTick ;
                        while xyData < GetMax() - (subTick / 2) do
                        begin
                            y := Rect.Bottom - FFaAxis.GetXY(yAxis, xyData) - 1;
                            DrawHori(Canvas, FGridColor, Rect.Left, y, Rect.Right) ;
                            xyData := xyData + subTick ;
                        end ;
                    end ;
                end ;
			end ;
		end ;
		Canvas.Pen.Style := sPStyle ;
		Canvas.Pen.Color := sPColor ;
	end ;
end ;
procedure TFaGraphEx.DrawLabel(index : Integer; x, y : Double; asText: String; Color : TColor) ;
begin
	if (index < 0) or (index > FFaSeries.Count - 1) then Exit ;
	if Printer.Printing then
		FFaSeries.Items[index].DrawLabel(Printer.Canvas, GetBoardRect() , x, y, asText, Color)
	else
    if FUserPreview     then
        FFaSeries.Items[index].DrawLabel(FUserCanvas, GetBoardRect() , x, y, asText, Color)
	else
		FFaSeries.Items[index].DrawLabel(FBorder.Canvas, GetBoardRect() , x, y, asText, Color) ;
end ;
//==============================================================================
// 주어진 x, y 좌표가 유효한 그래프 영역인가 아닌가.
//==============================================================================
function TFaGraphEx.GetBoardArea(Index : Integer; var areaRect : TRect) : Boolean;
begin
	Result := False ;
	if ((index < 0) or (index > FFaSeries.Count - 1)) then Exit ;
	with FFaSeries.Items[index] do
	begin
		areaRect.Left 	:= FFaAxis.FGraphRect.Left + FRect.Left + FFaAxis.GetLeftTop(FXAxis) ;
		areaRect.Top 	:= FFaAxis.FGraphRect.Top  + FRect.Bottom - FFaAxis.GetLeftTop(FYAxis) ;
		areaRect.Right  := FFaAxis.FGraphRect.Left + FRect.Left + FFaAxis.GetRightBottom(FXAxis) ;
		areaRect.Bottom	:= FFaAxis.FGraphRect.Top  + FRect.Bottom - FFaAxis.GetRightBottom(FYAxis) ;
	end ;
	Result := True ;
end ;
function TFaGraphEx.IsBoardXY(Index : Integer; x, y : Integer) : Boolean;
var
	areaRect : TRect ;
begin
	Result := False ;
	if not GetBoardArea(Index, areaRect) then Exit ;
	Result := Boolean((x >= areaRect.Left) and (x <= areaRect.Right) and
					  (y >= areaRect.Bottom ) and (y <= areaRect.Top)) ;
end ;
function TFaGraphEx.IsBoardX(Index : Integer; x : Integer) : Boolean;
var
	areaRect : TRect ;
begin
	Result := False ;
	if not GetBoardArea(Index, areaRect) then Exit ;
	Result := Boolean((x >= areaRect.Left) and (x <= areaRect.Right)) ;
end ;
function TFaGraphEx.IsBoardY(Index : Integer; y : Integer) : Boolean;
var
	areaRect : TRect ;
begin

	Result := False ;
	if not GetBoardArea(Index, areaRect) then Exit ;
	Result := Boolean((y >= areaRect.Bottom) and (y <= areaRect.Top)) ;
end ;

function TFaGraphEx.CalcXY(Index : Integer; x, y : Integer; var xData, yData : Double) : Boolean;
begin
	Result := IsBoardXY(Index, x, y) ;
	if Result then
	begin
		with FFaSeries.Items[index] do
		begin
			x := FRect.Left   + (x - FFaAxis.FGraphRect.Left) ;
			y := FRect.Bottom - (y - FFaAxis.FGraphRect.Top) ;
			xData := FFaAxis.CalcXY(FXAxis, x) ;
			yData := FFaAxis.CalcXY(FYAxis, y) ;
		end ;
	end ;
end ;
function TFaGraphEx.CalcX(Index : Integer; x : Integer; var xData : Double) : Boolean;
begin
	Result := IsBoardX(Index, x) ;
	if Result then
	begin
		with FFaSeries.Items[index] do
		begin
			x := FRect.Left   + (x - FFaAxis.FGraphRect.Left) ;
			xData := FFaAxis.CalcXY(FXAxis, x) ;
		end ;
	end ;
end ;
function TFaGraphEx.CalcY(Index : Integer; y : Integer; var yData : Double) : Boolean;
begin
	Result := IsBoardY(Index, y) ;
	if Result then
	begin
		with FFaSeries.Items[index] do
		begin
			y := FRect.Bottom - (y - FFaAxis.FGraphRect.Top) ;
			yData := FFaAxis.CalcXY(FYAxis, y) ;
		end ;
	end ;
end ;

function TFaGraphEx.FindXY(Index : Integer; x, y : Integer; var xData, yData : Double) : Boolean;
begin
	Result := IsBoardXY(Index, x, y) ;
	if Result then
	begin
		Result := Boolean(FindX(Index, x, xData) and FindY(Index, y, yData)) ;
	end ;
end ;
function TFaGraphEx.FindXY(Index : Integer; x, y : Integer; var xData, yData : Double; var xIndex, yIndex : Integer) : Boolean;
begin
	Result := IsBoardXY(Index, x, y) ;
	if Result then
	begin
		xIndex := FindX(Index, x, xData) ;
		yIndex := FindY(Index, y, yData) ;
		Result := Boolean((xIndex >= 0) and (yIndex >= 0)) ;
	end ;
end ;
function TFaGraphEx.FindX(Index : Integer; x : Integer; var xData : Double) : Integer;
begin
	Result := -1 ;
	if IsBoardX(Index, x) then
	begin
		if CalcX(Index, x, xData) then
		begin
			Result := FFaSeries.Items[index].FindX(xData) ;
		end ;
	end ;
end ;
function TFaGraphEx.FindY(Index : Integer; y : Integer; var yData : Double) : Integer;
begin
	Result :=  -1;
	if IsBoardY(Index, y) then
	begin
		if CalcY(Index, y, yData) then
		begin
			Result := FFaSeries.Items[index].FindY(yData) ;
		end ;
	end ;
end ;
//==============================================================================
//==============================================================================
procedure TFaGraphEx.XorOn() ;
begin
	Canvas.Pen.Mode := pmNotXor;
end ;
procedure TFaGraphEx.DragPush ;
begin
	if (FZoomSeries < 0) and (FZoomSeries >= FFaSeries.Count) then Exit ;
	if (FDragMode = dmPush) then
	begin
//		BeginUpdate() ;
	{
		if FDragAxisX = nil then FDragAxisX := TFaAxisRuler.Create(FFaAxis) ;
		if FDragAxisY = nil then FDragAxisY := TFaAxisRuler.Create(FFaAxis) ;

		FDragShowSaveX := FFaAxis.Items[FFaSeries.Items[FZoomSeries].AxisX].Showing ;
		FDragShowSaveY := FFaAxis.Items[FFaSeries.Items[FZoomSeries].AxisY].Showing ;

		FDragAxisX.Assign(FFaAxis.Items[FFaSeries.Items[FZoomSeries].AxisX]) ;
		FDragAxisY.Assign(FFaAxis.Items[FFaSeries.Items[FZoomSeries].AxisY]) ;

		FDragAxisX.Showing := False ;
		FDragAxisY.Showing := False ;
	}
		FRangeXmin := FFaAxis.Items[FFaSeries.Items[FZoomSeries].AxisX].Min ;
		FRangeXmax := FFaAxis.Items[FFaSeries.Items[FZoomSeries].AxisX].Max ;
		FRangeXstep := FFaAxis.Items[FFaSeries.Items[FZoomSeries].AxisX].Step ;
		FRangeXdec := FFaAxis.Items[FFaSeries.Items[FZoomSeries].AxisX].Decimal ;

		FRangeYmin := FFaAxis.Items[FFaSeries.Items[FZoomSeries].AxisY].Min ;
		FRangeYmax := FFaAxis.Items[FFaSeries.Items[FZoomSeries].AxisY].Max ;
		FRangeYstep := FFaAxis.Items[FFaSeries.Items[FZoomSeries].AxisY].Step ;
		FRangeYdec := FFaAxis.Items[FFaSeries.Items[FZoomSeries].AxisY].Decimal ;

//		EndUpdate() ;

		FDragMode := dmStart ;
	end ;
end ;
procedure TFaGraphEx.DragStart(x, y: Integer) ;
begin
	if (FZoomSeries < 0) and (FZoomSeries >= FFaSeries.Count) then Exit ;
	if (FDragMode = dmPush) then DragPush() ;
	if FDragMode in [dmStart, dmEnd] then
	begin
		XorOn() ;

		if CalcXY(FZoomSeries, x, y, FDragDataX, FDragDataY) then
		begin
			GetX(FZoomSeries, FDragDataX, FDragStart.X) ;
			GetY(FZoomSeries, FDragDataY, FDragStart.Y) ;

			Inc(FDragStart.X, FFaAxis.FGraphRect.Left) ;
			Inc(FDragStart.Y, FFaAxis.FGraphRect.Top) ;
			FDragStop := FDragStart ;
			(*
			Canvas.Pen.Style := psDot ;
			DrawBox(Canvas, GridColor, GridColor, FDragStart.X, FDragStart.Y, FDragStop.X, FDragStop.Y) ;
			Canvas.Pen.Style := psSolid ;
			*)
		end ;
		XorOff() ;
		FDragMode := dmDragging ;
	end ;
end ;
procedure TFaGraphEx.DragEnd(x, y : Integer) ;
var
	xData, yData : Double ;
		xMax, xMin, yMax, yMin : Double ;
		minStep : Double ;
begin
	if (FZoomSeries < 0) or (FZoomSeries >= FFaSeries.Count) then Exit ;
	if (FDragMode = dmDragging) then
	begin
//		BeginUpdate() ;

		if CalcXY(FZoomSeries, x, y, xData, yData) then
		begin
			xMax := Max(xData, FDragDataX) ;
			xMin := Min(xData, FDragDataX) ;
			yMax := Max(yData, FDragDataY) ;
			yMin := Min(yData, FDragDataY) ;

			with FFaAxis.Items[FFaSeries.Items[FZoomSeries].AxisX] do
			begin
				if Decimal = 0 then minStep := 0.5
				else                minStep := 1 / iPower(10, Decimal) ;
				if Abs(xMax - xMin) > minStep then
				begin
					Max := xMax ;
					Min := xMin ;
					Step:= (xMax - xMin) / 5 ;
				end ;
			end ;
			with FFaAxis.Items[FFaSeries.Items[FZoomSeries].AxisY] do
			begin
				if Decimal = 0 then minStep := 0.5
				else                minStep := 1 / iPower(10, Decimal) ;
				if Abs(yMax - yMin) > minStep then
				begin
					 Max := yMax ;
					 Min := yMin ;
					 Step:= (yMax - yMin) / 5 ;
				end ;
			end ;
		end ;
		FDragMode := dmEnd ;
//		EndUpdate() ;
	end ;
end ;
procedure TFaGraphEx.Draging(x, y : Integer) ;
var
	xData, yData : Double ;
begin
	if (FZoomSeries < 0) or (FZoomSeries >= FFaSeries.Count) then Exit ;

	if FDragMode = dmDragging then
	begin
		XorOn() ;
		Canvas.Pen.Style := psDot ;
		if not CompareMem(@FDragStart, @FDragStop, Sizeof(TRect)) then
			DrawBox(Canvas, GridColor, GridColor, FDragStart.X, FDragStart.Y, FDragStop.X, FDragStop.Y) ;

		if CalcXY(FZoomSeries, x, y, xData, yData) then
		begin
			GetX(FZoomSeries, xData, FDragStop.X) ;
			GetY(FZoomSeries, yData, FDragStop.Y) ;

			Inc(FDragStop.X, FFaAxis.FGraphRect.Left) ;
			Inc(FDragStop.Y, FFaAxis.FGraphRect.Top) ;
		end ;
		if not CompareMem(@FDragStart, @FDragStop, Sizeof(TRect)) then
			DrawBox(Canvas, GridColor, GridColor, FDragStart.X, FDragStart.Y, FDragStop.X, FDragStop.Y) ;
		Canvas.Pen.Style := psSolid ;
		XorOff() ;
	end ;
end ;
procedure TFaGraphEx.DragPop() ;
begin
	if (FZoomSeries < 0) or (FZoomSeries >= FFaSeries.Count) then Exit ;
	if FDragMode = dmEnd then
	begin
//		BeginUpdate() ;
		XorOff() ;

		{
		FFaAxis.Items[FFaSeries.Items[FZoomSeries].AxisX].Assign(FDragAxisX) ;
		FFaAxis.Items[FFaSeries.Items[FZoomSeries].AxisY].Assign(FDragAxisY) ;

		FFaAxis.Items[FFaSeries.Items[FZoomSeries].AxisX].Showing := FDragShowSaveX ;
		FFaAxis.Items[FFaSeries.Items[FZoomSeries].AxisY].Showing := FDragShowSaveY ;
		}
		FFaAxis.Items[FFaSeries.Items[FZoomSeries].AxisX].Min := FRangeXmin ;
		FFaAxis.Items[FFaSeries.Items[FZoomSeries].AxisX].Max := FRangeXmax ;
		FFaAxis.Items[FFaSeries.Items[FZoomSeries].AxisX].Step := FRangeXstep  ;
		FFaAxis.Items[FFaSeries.Items[FZoomSeries].AxisX].Decimal := FRangeXdec ;

		FFaAxis.Items[FFaSeries.Items[FZoomSeries].AxisY].Min := FRangeYmin ;
		FFaAxis.Items[FFaSeries.Items[FZoomSeries].AxisY].Max := FRangeYmax ;
		FFaAxis.Items[FFaSeries.Items[FZoomSeries].AxisY].Step := FRangeYstep ;
		FFaAxis.Items[FFaSeries.Items[FZoomSeries].AxisY].Decimal := FRangeYdec ;

//		EndUpdate() ;
		FDragMode := dmPush ;
	end ;
end ;
procedure TFaGraphEx.XorOff() ;
begin
	Canvas.Pen.Mode := pmCopy ;
end ;

procedure TFaGraphEx.DrawCrossBar(sIndex, x, y: Integer; barColor : TColor; barStyle : TPenStyle) ;
var
	xData, yData : Double ;
	xPos, yPos, x1, x2, y1, y2  : Integer ;
begin
	if (sIndex < 0) and (sIndex >= FFaSeries.Count) then Exit ;

	xOrOn() ;
	if CalcXY(sIndex, x, y, xData, yData) then
	begin
		GetX(sIndex, xData, xPos) ;
		GetX(sIndex, FFaAxis.Items[FFaSeries.Items[sIndex].AxisX].Min, x1) ;
		GetX(sIndex, FFaAxis.Items[FFaSeries.Items[sIndex].AxisX].Max, x2) ;

		GetY(sIndex, yData, yPos) ;
		GetY(sIndex, FFaAxis.Items[FFaSeries.Items[sIndex].AxisY].Min, y1) ;
		GetY(sIndex, FFaAxis.Items[FFaSeries.Items[sIndex].AxisY].Max, y2) ;

		Inc(xPos, FFaAxis.FGraphRect.Left) ;
		Inc(x1, FFaAxis.FGraphRect.Left) ;
		Inc(x2, FFaAxis.FGraphRect.Left) ;

		Inc(yPos, FFaAxis.FGraphRect.Top) ;
		Inc(y1, FFaAxis.FGraphRect.Top) ;
		Inc(y2, FFaAxis.FGraphRect.Top) ;

		Canvas.Pen.Style := barStyle ;
		if ggVert in FViewCrossBarDraw then DrawVert(Canvas, barColor, xPos, y1, y2) ;
		if ggHori in FViewCrossBarDraw then DrawHori(Canvas, barColor, x1, yPos, x2) ;
		Canvas.Pen.Style := psSolid ;
	end ;
	xOrOff() ;
end ;

function  TFaGraphEx.GetDragMode() : TDragMode ;
begin
	Result := FDragMode ;
end ;

//==============================================================================
//==============================================================================
function TFaGraphEx.GetXY(Index : Integer; x, y: Double; var tempCanvas: TCanvas; var xPos, yPos : Integer) : Boolean;
begin
	Result := False ;
	if (index < 0) or (index > FFaSeries.Count - 1) then Exit ;
	with FFaSeries.Items[index] do
	begin
		xPos := FRect.Left + FFaAxis.GetXY(FXAxis, x, true) ;
		yPos := FRect.Bottom - FFaAxis.GetXY(FYAxis, y, true) ;
		if Printer.Printing then tempCanvas := Printer.Canvas
        else
        if FUserPreview     then tempCanvas := FUserCanvas
        else                     tempCanvas := FBorder.Canvas ;
	end ;

	Result := True ;
end ;
function TFaGraphEx.GetX(Index : Integer; x: Double; var xPos : Integer) : Boolean ;
begin
	Result := False ;
	if (index < 0) or (index > FFaSeries.Count - 1) then Exit ;

	with FFaSeries.Items[index] do	xPos := FRect.Left + FFaAxis.GetXY(FXAxis, x) ;

	Result := True ;
end ;
function TFaGraphEx.GetY(Index : Integer; y: Double; var yPos : Integer) : Boolean ;
begin
	Result := False ;
	if (index < 0) or (index > FFaSeries.Count - 1) then Exit ;

	with FFaSeries.Items[index] do	yPos := FRect.Bottom - FFaAxis.GetXY(FYAxis, y) - 1;
//	yPos := Rect.Bottom - TFaSeries(GetOwner).FFaAxis.GetXY(FYAxis, y) ;

	Result := True ;
end ;
procedure TFaGraphEx.GetCanvas(var tempCanvas: TCanvas) ;
begin
	if Printer.Printing then tempCanvas := Printer.Canvas
    else
    if FUserPreview     then tempCanvas := FUserCanvas
	else                     tempCanvas := FBorder.Canvas ;
end ;

procedure TFaGraphEx.DrawData(siIndex: array of Integer) ;
var
	//serieIndex : Integer ;
	axisIndex : Integer ;
	cmSave : LongInt ;
begin
	if FUpdateCount <> 0 then Exit ;

    if (FGraphType = gtAutoScroll) then
    begin
    	FFaSeries.DrawData(FBorder.Canvas, GetBoardRect())
    end
    else
    begin
        if FGraphType = gtNormal then
        begin
            FFaSeries.DrawScrollData(FBorder.Canvas, GetBoardRect(),  siIndex);
        end
        else
        begin
            FFaSeries.DrawScrollData(FBorder.Canvas, GetBoardRect() );
        end ;
    end ;

	cmSave := Canvas.CopyMode ;
    Canvas.CopyMode := cmSrcCopy ;

	if not Printer.Printing and not FUserPreview then
	begin
        {
		for serieIndex := 0 to FFaSeries.Count - 1 do
		begin
			if (FSdShare.GetMaxIndex(FFaSeries.Items[serieIndex].ShareX) > 0) then
			begin
				for axisIndex := 0 to FFaAxis.Count - 1 do
				begin
					if FFaAxis.Items[axisIndex].Align in [aaVertCenter, aaHoriCenter] then
					begin
                        if FBoardColor = clBlack then Canvas.CopyMode := cmSrcPaint
                        else                          Canvas.CopyMode := cmSrcAnd ;
						Break ;
					end ;
				end ;
			end ;
		end ;
        }
        for axisIndex := 0 to FFaAxis.Count - 1 do
        begin
            if FFaAxis.Items[axisIndex].Align in [aaVertCenter, aaHoriCenter] then
            begin
                if FBoardColor = clBlack then Canvas.CopyMode := cmSrcPaint
                else                          Canvas.CopyMode := cmSrcAnd ;
                Break ;
            end ;
        end ;
	end ;

	if not FLock then
    begin
        //======
        // 일정시간안이면 화면갱신 안한다...
        //===
        if not FUpdateDelayEnabled or (FUpdateDelayEnabled and (FCUpdateDelayTime.READ() >= FUpdateDelayTime)) then
        begin
            FCUpdateDelayTime.START() ;
            BitBlt(Canvas.Handle, FFaAxis.FGraphRect.Left, FFaAxis.FGraphRect.Top, FBorder.Width, FBorder.Height, FBorder.Canvas.Handle, 0, 0, Canvas.CopyMode);
            //BitBlt(Canvas.Handle, FFaAxis.FGraphRect.Left, FFaAxis.FGraphRect.Top, FBorder.Width, FBorder.Height, FBorder.Canvas.Handle, 0, 0, cmSrcCopy{SRCCOPY});
        end ;
    end ;

	Canvas.CopyMode := cmSave ;
end ;
procedure TFaGraphEx.DrawData(Canvas : TCanvas; Rect: TRect);
begin
	if FUpdateCount <> 0 then Exit ;
	if FGraphType = gtView then
	begin
		FFaSeries.DrawViewData(Canvas, Rect, FViewStart);
	end
	else
	begin
		FFaSeries.DrawData(Canvas, Rect);
	end ;
end ;
procedure TFaGraphEx.DrawFrame(Canvas : TCanvas; Rect: TRect) ;
begin
	if FUpdateCount <> 0 then Exit ;

    if gsSide_1 in FGridDrawSide then
    begin
    	DrawVert(Canvas, FOutnerFrameColor, Rect.Right, Rect.Top, (Rect.Top + Rect.Bottom) div 2) ;
        DrawHori(Canvas, FOutnerFrameColor, (Rect.Left + Rect.Right) div 2, Rect.Top, Rect.Right) ;
    end ;
    if gsSide_2 in FGridDrawSide then
    begin
    	DrawVert(Canvas, FOutnerFrameColor, Rect.Right, (Rect.Top + Rect.Bottom) div 2, Rect.Bottom) ;
        DrawHori(Canvas, FOutnerFrameColor, (Rect.Left + Rect.Right) div 2, Rect.Bottom, Rect.Right) ;
    end ;
    if gsSide_3 in FGridDrawSide then
    begin
    	DrawVert(Canvas, FOutnerFrameColor, Rect.Left, (Rect.Top + Rect.Bottom) div 2, Rect.Bottom) ;
        DrawHori(Canvas, FOutnerFrameColor, Rect.Left, Rect.Bottom, (Rect.Left + Rect.Right) div 2) ;
    end ;
    if gsSide_4 in FGridDrawSide then
    begin
    	DrawVert(Canvas, FOutnerFrameColor, Rect.Left, Rect.Top, (Rect.Top + Rect.Bottom) div 2) ;
        DrawHori(Canvas, FOutnerFrameColor, Rect.Left, Rect.Top, (Rect.Left + Rect.Right) div 2) ;
    end ;

//	DrawBox(Canvas, clBlack, clBlack, Rect.Left, Rect.Top, Rect.Right, Rect.Bottom) ;
end ;
procedure TFaGraphEx.Draw() ;
var
	R  : TRect ;
begin
	if Printer.Printing or FUserPreview then Exit ;
	//if Printer.Printing  then Exit ;

    if Canvas.Font <>  Font then Canvas.Font.Assign(Font) ;
	//if FBorder.Canvas.Brush <> Canvas.Brush then FBorder.Canvas.Brush.Assign(Canvas.Brush) ;
	//if FBorder.Canvas.Pen  <> Canvas.Pen then FBorder.Canvas.Pen.Assign(Canvas.Pen) ;
	if FBorder.Canvas.Font <>  Canvas.Font then FBorder.Canvas.Font.Assign(Canvas.Font) ;

	with R do
	begin
		Left 	:= ClientRect.Left 		+ Space.Left ;
		Right 	:= ClientRect.Right 	- Space.Right ;
		Top 	:= ClientRect.Top 		+ Space.Top ;
		Bottom 	:= ClientRect.Bottom 	- Space.Bottom ;
	end ;

    Canvas.Brush.Color := Color ;
    //Canvas.FillRect(Bounds(0, 0, Width, Height)) ;
	if not CompareMem(@FFaAxis.FAxisRect, @R, Sizeof(TRect)) then
	begin
		R := FFaAxis.SetInitial(Canvas, R) ;
	end
	else
	begin
		R := FFaAxis.Recalc ;
	end ;
	if R.Right - R.Left + 1 > 16 then
	begin
		if FBorder.Width <> (R.Right - R.Left + 1) then FBorder.Width := R.Right - R.Left + 1 ;
	end ;
	if R.Bottom - R.Top + 1 > 16 then
	begin
		if FBorder.Height <> (R.Bottom - R.Top + 1) then FBorder.Height := R.Bottom - R.Top + 1;
	end ;

	with FBorder do
	begin
		Canvas.Brush.Color := FBoardColor ;
		Canvas.Pen.Color := FGridColor ;

        // BRUSH TEST
		SetBoardRect(Bounds(0, 0, FBorder.Width, FBorder.Height)) ;
		Canvas.FillRect(Bounds(0, 0, FBorder.Width, FBorder.Height)) ;

		if Assigned(FOnBeforePaint) then FOnBeforePaint(Self);
		DrawGrid(Canvas, Bounds(0, 0, Width, Height)) ;
		DrawData(Canvas, Bounds(0, 0, Width, Height)) ;
		if Assigned(FOnAfterPaint) then FOnAfterPaint(Self);
	end ;
	//Canvas.Draw(R.Left, R.Top, FBorder);
    //BitBlt(Canvas.Handle, R.Left, R.Top, FBorder.Width, FBorder.Height, FBorder.Canvas.Handle, 0, 0, Canvas.CopyMode);
    BitBlt(Canvas.Handle, R.Left, R.Top, FBorder.Width, FBorder.Height, FBorder.Canvas.Handle, 0, 0, cmSrcCopy);

	if FOutnerFrame then DrawFrame(Canvas, Bounds(R.Left - 1, R.Top - 1, FBorder.Width + 1, FBorder.Height + 1)) ;
//	if FOutnerFrame then DrawFrame(Canvas, Bounds(R.Left, R.Top, FBorder.Width, FBorder.Height)) ;
end ;
procedure TFaGraphEx.Print(mCanvas : TCanvas; Rect: TRect; APreview: boolean; ARgn : Boolean);
var
	R, Rgn  : TRect ;
	hdlRgn : HRGN ;
begin
    FUserPreview := APreview ;
    FUserCanvas  := mCanvas ;

	try
		with Rect do
		begin
			Inc(Left, Space.Left) ;
			Inc(Top, Space.Top) ;
			Dec(Right, Space.Right) ;
			Dec(Bottom, Space.Bottom) ;
		end ;
		mCanvas.Brush.Color := clWhite ;
		R := FFaAxis.SetInitial(mCanvas, Rect) ;

		Rgn := R ;
		Inc(Rgn.Top) ;
		Dec(Rgn.Bottom) ;
		Inc(Rgn.Left) ;
		Dec(Rgn.Right) ;
		LPtoDP(mCanvas.Handle, Rgn, 2);

		SetBoardRect(R) ;

		if not ARgn and Assigned(FOnBeforePaint) then FOnBeforePaint(Self);
		hdlRgn := CreateRectRgn(Rgn.Left, Rgn.Top, Rgn.Right, Rgn.Bottom);
		try
			SelectClipRgn(mCanvas.Handle, hdlRgn);

			if ARgn and Assigned(FOnBeforePaint) then FOnBeforePaint(Self);

			DrawGrid(mCanvas, R) ;
			DrawData(mCanvas, R) ;
		finally
			if ARgn and Assigned(FOnAfterPaint) then FOnAfterPaint(Self);
			DeleteObject(hdlRgn) ;
			SelectClipRgn(mCanvas.Handle, 0);
			if FOutnerFrame then DrawFrame(mCanvas, R) ;
			if not ARgn and Assigned(FOnAfterPaint) then FOnAfterPaint(Self);
		end ;
	finally
		Draw() ;
		FFaAxis.DrawRuler ;

        FUserPreview := false ;
	end ;
end ;
//---------------------------------------------------------------------------
function TFaGraphEx.GetDefaultXAxis : Integer ;
var
	index, xAxis : Integer ;
begin
	xAxis := -1 ;
	for index := 0 to FFaAxis.Count - 1 do
	begin
		if xAxis < 0 then
		begin
			if FFaAxis.Items[index].Align in [aaTop, aaBottom, aaHoriCenter] then xAxis := index ;
		end ;
	end ;
	Result := xAxis ;
end ;
function TFaGraphEx.GetDefaultYAxis : Integer ;
var
	index, yAxis : Integer ;
begin
	yAxis := -1 ;
	for index := 0 to FFaAxis.Count - 1 do
	begin
		if yAxis < 0 then
		begin
			if FFaAxis.Items[index].Align in [aaLeft, aaRight, aaVertCenter] then yAxis := index ;
		end ;
	end ;
	Result := yAxis ;
end ;
procedure TFaGraphEx.View(gvView : TFaGraphView) ;
	procedure GetViewRange(gvView : TFaGraphView);
	var
		xdIndex, cIndex, xAxis: Integer ;
		xTemp, xData    	: Double ;
	begin
		xdIndex := GetDefaultXAxis ;
		xAxis := FFaSeries.Items[FZoomSeries].ShareX ;
		if xAxis >= 0 then
		begin
			with FFaAxis.Items[xdIndex] do
			begin
				case gvView of
					gvNext,
					gvNextStep,
					gvNextPage:
					begin
						for cIndex := FViewStart + 1 to FSdShare.GetMaxIndex(xAxis) - 1 do
						begin
							FSdShare.GetData(xAxis, cIndex, xData) ;
							if xData >= Min then
							begin
								FViewStart := cIndex ;
								Break ;
							end ;
						end ;
						if cIndex = FSdShare.GetMaxIndex(xAxis) - 1 then FViewStart := cIndex ;
					end ;
					gvLast:
					begin
						for cIndex := FSdShare.GetMaxIndex(xAxis) - 1 downto 0 do
						begin
							FSdShare.GetData(xAxis, cIndex, xData) ;
							if xData <= Min then
							begin
								if cIndex > 0 then
								begin
									FSdShare.GetData(xAxis, cIndex - 1, xTemp) ;
									if xTemp = xData then
										FViewStart := cIndex - 1
									else
										FViewStart := cIndex ;
								end
								else
								begin
									FViewStart := cIndex ;
								end ;
								break ;
							end ;
						end ;
						if cIndex = 0 then FViewStart := cIndex ;
					end ;
					gvPrev,
					gvPrevStep,
					gvPrevPage:
					begin
						for cIndex := FViewStart - 1 downto 0 do
						begin
							FSdShare.GetData(xAxis, cIndex, xData) ;
							if xData <= Min then
							begin
								if cIndex > 0 then
								begin
									FSdShare.GetData(xAxis, cIndex - 1, xTemp) ;
									if xTemp = xData then
										FViewStart := cIndex - 1
									else
										FViewStart := cIndex ;
								end
								else
								begin
									FViewStart := cIndex ;
								end ;
								Break ;
							end ;
						end ;
						if cIndex = 0 then FViewStart := cIndex ;
					end ;
					gvFirst:
					begin
						FViewStart := 0 ;
					end ;
				end ;
			end ;
		end ;
	end ;
var
	xdIndex, xAxis, cIndex : Integer ;
	w, xData, xMax : Double ;
begin
	xdIndex := GetDefaultXAxis ;
	xAxis := FFaSeries.Items[FZoomSeries].ShareX ;
	if xAxis >= 0 then
	begin
	Screen.Cursor := crHourglass ;
	try
		Inc(FUpdateCount) ;
		with FFaAxis.Items[xdIndex] do
		begin
			w := Max - Min ;
			case gvView of
				gvNext:
				begin
					FSdShare.GetData(xAxis, FViewStart + 1, xData) ;
					FSdShare.GetData(xAxis, FSdShare.GetMaxIndex(xAxis) - 1, xMax) ;
					if xMax <> Max then
					begin
						if xData + w <= xMax then
						begin
							if (Min = xData) then
							begin
								Inc(FViewStart) ;
								FSdShare.GetData(xAxis, FViewStart + 1, xData) ;
							end ;
							Min := xData ;
							Max := xData + w ;
							if (Max > xMax) then
							begin
								Dec(FViewStart) ;
								Min := xMax - w ;
								Max := xMax ;
							end
							else GetViewRange(gvNext) ;
						end
						else
						begin
							Min := xMax - w ;
							Max := xMax ;
						end ;
					end ;
				end ;
				gvPrev:
				begin
					if FViewStart > 0 then
					begin
						FSdShare.GetData(xAxis, FViewStart - 1, xData) ;
						if Min = xData then
						begin
							if FViewStart > 1 then
							begin
								Dec(FViewStart) ;
								FSdShare.GetData(xAxis, FViewStart - 1, xData)
							end ;
						end ;
					end
					else FSdShare.GetData(xAxis, 0, xData) ;

					Min := xData ;
					Max := xData + w ;
					GetViewRange(gvPrev) ;
				end ;
				gvNextStep:
				begin
					FSdShare.GetData(xAxis, FSdShare.GetMaxIndex(xAxis) - 1, xMax) ;
					if Max + Step < xMax then
					begin
						Min := Min + Step ;
						Max := Max + Step ;
					end
					else
					begin
						Min := xMax - w ;
						Max := xMax ;
					end ;
					for cIndex := FViewStart to FSdShare.GetMaxIndex(xAxis) - 1 do
					begin
						FSdShare.GetData(xAxis, cIndex, xData) ;
						if xData >= Min then
						begin
							Min := xData ;
							Max := xData + w ;
							FViewStart := cIndex ;
							Break ;
						end ;
					end ;
					if cIndex = FSdShare.GetMaxIndex(xAxis) - 1 then FViewStart := cIndex ;
				end ;
				gvPrevStep:
				begin
					FSdShare.GetData(xAxis, 0, xData) ;
					if Min - Step > xData then
					begin
						Max := Max - Step;
						Min := Min - Step ;
					end
					else
					begin
						Min := xData ;
						Max := xData + w ;
					end ;
					//GetViewRange(gvPrevStep) ;

					for cIndex := FViewStart downto 0 do
					begin
						FSdShare.GetData(xAxis, cIndex, xData) ;
						if xData <= Min then
						begin
							if cIndex > 0 then
							begin
								FSdShare.GetData(xAxis, cIndex - 1, xMax) ;
								if xMax = xData then
									FViewStart := cIndex - 1
								else
									FViewStart := cIndex ;
							end
							else
							begin
								FViewStart := cIndex ;
							end ;
							Min := xData ;
							Max := xData + w ;
							Break ;
						end ;
					end ;
					if cIndex = 0 then FViewStart := cIndex ;

				end ;
				gvNextPage:
				begin
					FSdShare.GetData(xAxis, FSdShare.GetMaxIndex(xAxis) - 1, xMax) ;
					if Max + w < xMax then
					begin
						Min := Max ;
						Max := Max + w ;
					end
					else
					begin
						Min := xMax - w ;
						Max := xMax ;
					end ;
					for cIndex := FViewStart to FSdShare.GetMaxIndex(xAxis) - 1 do
					begin
						FSdShare.GetData(xAxis, cIndex, xData) ;
						if xData >= Min then
						begin
							Min := xData ;
							Max := xData + w ;
							FViewStart := cIndex ;
							Break ;
						end ;
					end ;
					if cIndex = FSdShare.GetMaxIndex(xAxis) - 1 then FViewStart := cIndex ;
				end ;
				gvPrevPage:
				begin
					FSdShare.GetData(xAxis, 0, xData) ;
					if Min - w > xData then
					begin
						Max := Min ;
						Min := Max - w ;
					end
					else
					begin
						Min := xData ;
						Max := xData + w ;
					end ;
					//GetViewRange(gvPrevPage) ;

					for cIndex := FViewStart downto 0 do
					begin
						FSdShare.GetData(xAxis, cIndex, xData) ;
						if xData <= Min then
						begin
							if cIndex > 0 then
							begin
								FSdShare.GetData(xAxis, cIndex - 1, xMax) ;
								if xMax = xData then
									FViewStart := cIndex - 1
								else
									FViewStart := cIndex ;
							end
							else
							begin
								FViewStart := cIndex ;
							end ;
							Min := xData ;
							Max := xData + w ;
							Break ;
						end ;
					end ;
					if cIndex = 0 then FViewStart := cIndex ;
				end ;
				gvFirst:
				begin
					FSdShare.GetData(xAxis, 0, xData) ;
					Min := xData ;
					Max := xData + w ;
					GetViewRange(gvFirst) ;
				end ;
				gvLast:
				begin
					FSdShare.GetData(xAxis, FSdShare.GetMaxIndex(xAxis) - 1, xMax) ;
					Max := xMax ;
					Min := xMax - w ;
					GetViewRange(gvLast) ;
				end ;
			end ;
		end ;
	finally
		Dec(FUpdateCount);
		FFaAxis.DrawLabel(xdIndex) ;
		Draw ;
		Screen.Cursor := crdefault ;
	end ;
	end ;
end ;

procedure TFaGraphEx.Update;
begin
	if FUpdateCount = 0 then Invalidate() ;
end;

procedure TFaGraphEx.BeginUpdate;
begin
	Inc(FUpdateCount);
end;

procedure TFaGraphEx.EndUpdate;
begin
	Dec(FUpdateCount);
	if FUpdateCount = 0 then Update() ;
end ;


procedure TFaGraphEx.SetLock ;
begin
    FLock := true ;
end ;

procedure TFaGraphEx.SetUnLock ;
begin
    if FLock then
    begin
        FLock := false ;
        Update() ;
    end ;
end ;

procedure TFaGraphEx.Paint;
begin
	if Printer.Printing then Exit ;
	if FUpdateCount <> 0 then Exit ;
	if FViewCrossBar then FViewCrossStatus  := 0 ;
	Draw ;
	FFaAxis.DrawRuler ;
end ;

procedure TFaGraphEx.onDrawCrossBar(x, y : Integer) ;
begin
	if FViewCrossBar and (FZoomSeries >= 0) then
	begin
		if FViewCrossStatus < 2 then
		begin
			if FViewCrossStatus = 1 then DrawCrossBar(FZoomSeries,  FViewCrossPoint.X, FViewCrossPoint.Y) ;
			if IsBoardXY(FZoomSeries, x, y) then
			begin
				DrawCrossBar(FZoomSeries, x, y) ;
				FViewCrossPoint.X := x ;
				FViewCrossPoint.Y := y ;
				FViewCrossStatus  := 1 ;
			end
			else
			begin
				FViewCrossStatus  := 0 ;
			end ;
		end
		else
		begin
			if FViewCrossStatus = 3 then FViewCrossStatus := 0 ;
		end ;
	end ;
end ;
procedure TFaGraphEx.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
	inherited MouseDown(Button, Shift, X, Y);

	if FZoomMode then
	begin
		if FViewCrossBar then FViewCrossStatus  := 2 ;
		if Button = mbLeft then DragStart(X, Y)
		else if Button = mbRight then DragPop() ;
	end ;
end;

procedure TFaGraphEx.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
	inherited MouseMove(Shift, X, Y);

	if FZoomMode then
	begin
		Draging(X, Y) ;
	end ;
	if FViewCrossBar then onDrawCrossBar(x, y) ;
end;

procedure TFaGraphEx.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
	inherited MouseUp(Button, Shift, X, Y);

	if FZoomMode then
	begin
		if FViewCrossBar then FViewCrossStatus  := 3 ;
		if Button = mbLeft then DragEnd(X, Y) ;
	end ;
end;

end.
