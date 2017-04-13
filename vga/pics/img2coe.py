from scipy import misc
import numpy as np


def img2coe(input: str, output: str):
    pic = misc.imread(input)
    height = pic.shape[0]
    width = pic.shape[1]

    with open(output, 'w') as f:
        f.write('%s\n' % '; VGA Memory Map ')
        f.write('%s\n' % '; .COE file with hex coefficients ')
        f.write('; Height: %d, Width: %d\n\n' % (height, width))
        f.write('%s\n' % 'memory_initialization_radix=16;')
        f.write('%s\n' % 'memory_initialization_vector=')

        cnt = 0
        for r in range(0, height):
            for c in range(0, width):
                cnt += 1
                R, G, B = pic[r][c][0], pic[r][c][1], pic[r][c][2]
                Rb, Gb, Bb = np.binary_repr(R, width=4), np.binary_repr(G, width=4), np.binary_repr(B, width=4)
                out_byte = np.append(Rb[1:3], [Gb[1: 3], Bb[1: 2]])
                print(out_byte)

        """
        cnt = 0;
        img2 = img;
        for r=1:height
            for c=1:width
                cnt = cnt + 1;
                R = img(r,c,1);
                G = img(r,c,2);
                B = img(r,c,3);
                Rb = dec2bin(R,8);
                Gb = dec2bin(G,8);
                Bb = dec2bin(B,8);
                img2(r,c,1) = bin2dec([Rb(1:3) '00000']);
                img2(r,c,2) = bin2dec([Gb(1:3) '00000']);
                img2(r,c,3) = bin2dec([Bb(1:2) '000000']);
                Outbyte = [ Rb(1:3) Gb(1:3) Bb(1:2) ];
                if (Outbyte(1:4) == '0000')
                    fprintf(s,'0%X',bin2dec(Outbyte));
                else
                    fprintf(s,'%X',bin2dec(Outbyte));
                end
                if ((c == width) && (r == height))
                    fprintf(s,'%c',';');
                else
                    if (mod(cnt,32) == 0)
                        fprintf(s,'%c\n',',');
                    else
                        fprintf(s,'%c',',');
                    end
                end
            end
        end
        """

if __name__ == "__main__":
    img2coe("benc.png", "benc.coe")

