using SonicRetro.SonLVL.API;
 
namespace CustomLayout
{
   public class CustomLayout : LayoutFormatSeparate
   {
       private void ReadLayoutInternal(byte[] rawdata, ref ushort[,] layout, ref bool[,] loop)
       {
           layout = new ushort[MaxSize.Width, MaxSize.Height];
           loop = new bool[MaxSize.Width, MaxSize.Height];
           for (int lr = 0; lr < MaxSize.Height; lr++)
               for (int lc = 0; lc < MaxSize.Width; lc++)
               {
                   if ((lr * MaxSize.Width) + lc >= rawdata.Length) break;
                   layout[lc, lr] = (byte)(rawdata[(lr * MaxSize.Width) + lc] & 0x7F);
                   loop[lc, lr] = (rawdata[(lr * MaxSize.Width) + lc] & 0x80) == 0x80;
               }
       }
 
       public override void ReadFG(byte[] rawdata, LayoutData layout)
       {
           ReadLayoutInternal(rawdata, ref layout.FGLayout, ref layout.FGLoop);
       }
 
       public override void ReadBG(byte[] rawdata, LayoutData layout)
       {
           ReadLayoutInternal(rawdata, ref layout.BGLayout, ref layout.BGLoop);
       }
 
       private void WriteLayoutInternal(ushort[,] layout, bool[,] loop, out byte[] rawdata)
       {
           rawdata = new byte[MaxSize.Width * MaxSize.Height];
           int c = 0;
           for (int lr = 0; lr < MaxSize.Height; lr++)
               for (int lc = 0; lc < MaxSize.Width; lc++)
                   rawdata[c++] = (byte)(layout[lc, lr] | (loop[lc, lr] ? 0x80 : 0));
       }
 
       public override void WriteFG(LayoutData layout, out byte[] rawdata)
       {
           WriteLayoutInternal(layout.FGLayout, layout.FGLoop, out rawdata);
       }
 
       public override void WriteBG(LayoutData layout, out byte[] rawdata)
       {
           WriteLayoutInternal(layout.BGLayout, layout.BGLoop, out rawdata);
       }
 
       public override bool HasLoopFlag { get { return true; } }
 
       public override bool IsResizable { get { return false; } }
 
       public override System.Drawing.Size MaxSize { get { return new System.Drawing.Size(128, 8); } }
   }
}
