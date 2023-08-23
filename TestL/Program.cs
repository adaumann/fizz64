namespace TestL
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Random rand = new Random();

            for (int i = 80; i >= 0; i--)
            {
                double angle = rand.NextDouble() * 360; // angle in degrees

                int length = rand.Next(0, i);

                double x = length * Math.Cos(angle);
                double y = length * Math.Sin(angle);
                do
                {
                    length = rand.Next(0, i);
                    y = length * Math.Sin(angle);
                    
                } while (y < -30 || y > 30);

                int x1 = (int)Math.Round(x) + 80;
                int y1 = (int)Math.Round(y) + 60;

                Console.WriteLine("x1: " + x1 + " y1: " + y1);

                // do something with x and y coordinates
            }
        }
    }
}