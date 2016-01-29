SndBuf x => dac;
x => FFT fft => blackhole;

me.dir() + "data/colleen_everyone.wav" => x.read;

1024 => fft.size;
Windowing.hamming(fft.size()) => fft.window;
second/samp => float sr;
200 => int frames;
(fft.size()/2) + 1 => int bins;
<<<frames + " : " + bins>>>;
float X[frames][bins];

//analysis phase
0 => int counter;
x.samples()/2 => x.pos;
for(int frame; frame < frames; frame++){
  fft.upchuck() @=> UAnaBlob blob;
  100::ms => now;
  for(int i; i < bins-1; i++){
    blob.fvals()[i] => X[frame][i];
  }
}

<<<"calculating">>>;

organize(X) @=> int new_order[];

for(int i; i < new_order.size(); i++){
  /*<<<i + ": " +  new_order[i]>>>;*/
  ((new_order[i] * (100 * 44.1))$int)+x.samples()/2 => x.pos;
  100::ms => now;
}

fun int[] organize(float blobs[][]){
  int organized[0];
  for(int i; i < blobs.size(); i++){
    100.0 => float lowest;
    100 => int lowest_index;
    1 => int free;
    for(int j; j < blobs.size(); j++){
      if(i != j){
        for(int k; k < organized.size()-1; k++){
          if(j == organized[k]){
            0 => free;
          }
        }
        if(free){
          blobs[i] @=> float main[];
          blobs[j] @=> float sub[];
          /*<<<main[100] + " : " + sub[100]>>>;*/
          compare(main, sub) => float comp;
          if(comp < lowest){
            comp => lowest;
            j => lowest_index;
          }
        }else{
          1 => free;
        }
      }
    }
    organized << lowest_index;
  }
  return organized;
}

//thanks http://music.columbia.edu/~daniglesia/research/fftsplice/
fun float compare(float a[], float b[]){
  0 => float eval;
  for(int i; i < fft.size()/2; i++){
    /*<<<a[i] + " : " + b[i]>>>;*/
    Std.fabs(a[i] - b[i]) + eval => eval;
  }
  return eval;
}




