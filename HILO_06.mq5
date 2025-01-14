//+------------------------------------------------------------------+
//|                                    HiLo Candle Color HiLo_06.mq5 |
//|                                        Ricardo José alves Júnior |
//|                                         ricardo.junior@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Ricardo José alves Júnior"
#property link      "ricardo.junior@gmail.com"
#property version   "1.00"

#property indicator_chart_window

#property indicator_buffers 11
#property indicator_plots   1
//--- plot 1
#property indicator_label1  ""
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrGold,clrGreen,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
input int InpPeriodHiLo = 20; // Period
input int InpShiftHiLo = 0; // Shift
input ENUM_MA_METHOD InpSmoothingMethodHiLo = MODE_EMA; // Smoothing method


//--- input parameters
//---- indicator buffers
double Candle_Open[];
double Candle_High[];
double Candle_Low[];
double Candle_Close[];
double Candle_Color[];

// HILO buffers
double OpenBuffer[], HighBuffer[], LowBuffer[], CloseBuffer[];
double HMABuffer[], LMABuffer[];

//--- indicator handles
int handleHighMA, handleLowMA;

//--- list global variable
string prefix="Candlestick Type ";
string name[]={"MARIBOZU","DOJI","SPINNING TOP","HAMMER","TURN HAMMER","LONG","SHORT"};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Candle indicator buffers mapping
   SetIndexBuffer(0,Candle_Open,INDICATOR_DATA);
   SetIndexBuffer(1,Candle_High,INDICATOR_DATA);
   SetIndexBuffer(2,Candle_Low,INDICATOR_DATA);
   SetIndexBuffer(3,Candle_Close,INDICATOR_DATA);
   SetIndexBuffer(4,Candle_Color,INDICATOR_CALCULATIONS);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

  // set the index for buffers
  SetIndexBuffer(5, OpenBuffer, INDICATOR_CALCULATIONS);
  SetIndexBuffer(6, HighBuffer, INDICATOR_CALCULATIONS);
  SetIndexBuffer(7, LowBuffer, INDICATOR_CALCULATIONS);
  SetIndexBuffer(8, CloseBuffer, INDICATOR_CALCULATIONS);
  SetIndexBuffer(9, HMABuffer, INDICATOR_CALCULATIONS);
  SetIndexBuffer(10, LMABuffer, INDICATOR_CALCULATIONS);

//---- sets drawing line empty value--
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---
  // get indicator handles
  handleHighMA = iMA(Symbol(), Period(), InpPeriodHiLo, InpShiftHiLo, InpSmoothingMethodHiLo, PRICE_HIGH);
  handleLowMA = iMA(Symbol(), Period(), InpPeriodHiLo, InpShiftHiLo, InpSmoothingMethodHiLo, PRICE_LOW);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {

   if(rates_total==prev_calculated)
     {
      return(rates_total);
     }
   Candle_Open[rates_total-1]=EMPTY_VALUE;
   Candle_High[rates_total-1]=EMPTY_VALUE;
   Candle_Low[rates_total-1]=EMPTY_VALUE;
   Candle_Close[rates_total-1]=EMPTY_VALUE;
   
  int statusHMA = CopyBuffer(handleHighMA, 0, 0, rates_total, HMABuffer);
  int statusLMA = CopyBuffer(handleLowMA, 0, 0, rates_total, LMABuffer);
  int Hld = 0;
  int Hlv = 0;

   int limit;
   if((statusHMA > 0) && (statusLMA > 0) && (prev_calculated==0))
      limit=20;
   else limit=prev_calculated-5;

//--- calculate candlestick
   for(int i=limit;i<rates_total-1;i++)
     {
      Candle_Open[i]=open[i];
      Candle_High[i]=high[i];
      Candle_Low[i]=low[i];
      Candle_Close[i]=close[i];

      OpenBuffer[i] = EMPTY_VALUE;
      HighBuffer[i] = EMPTY_VALUE;
      LowBuffer[i] = EMPTY_VALUE;
      CloseBuffer[i] = EMPTY_VALUE;

      if(close[i] >= HMABuffer[i - 1])
        Hld = 1;
      else
      if(close[i] <= LMABuffer[i - 1])
        Hld = -1;
      else
        Hld = 0;

      if(Hld != 0)
        Hlv = Hld;

      if(Hlv == -1) {
        OpenBuffer[i] = HMABuffer[i - 1];
        HighBuffer[i] = HMABuffer[i - 1];
        LowBuffer[i] = HMABuffer[i];
        CloseBuffer[i] = HMABuffer[i];
        Candle_Color[i] = 2;                                        
      }
      else {
        OpenBuffer[i] = LMABuffer[i - 1];
        HighBuffer[i] = LMABuffer[i];
        LowBuffer[i] = LMABuffer[i - 1];
        CloseBuffer[i] = LMABuffer[i];
        Candle_Color[i] = 1;                                         
      }
      
      if((OpenBuffer[i] > open[i] && OpenBuffer[i-1] < open[i]) ||  
         (OpenBuffer[i] < open[i] && OpenBuffer[i-1] > open[i]))    
         {                                                          
         
            Candle_Color[i] = 0;                                     
         }                                                          

      
    }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
