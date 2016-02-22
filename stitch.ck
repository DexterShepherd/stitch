SndBuf x => Gain mute => dac;
x => FFT fft => blackhole;
dac => WvOut w => blackhole;
0 => w.record;
0 => mute.gain;
"data/post_foetus_processed.wav" => w.wavFilename;

me.dir() + "data/out.wav" => x.read;

150 => int chunk_size;

1024 => fft.size;
Windowing.hamming(fft.size()) => fft.window;
second/samp => float sr;
(((x.samples()/sr)*1000)/chunk_size)$int=> int frames;

(fft.size()/2) + 1 => int bins;
<<<frames + " : " + bins>>>;
float X[frames][bins];

//analysis phase
0 => int counter;
for(int frame; frame < frames; frame++){
  fft.upchuck() @=> UAnaBlob blob;
  chunk_size::ms => now;
  for(int i; i < bins-1; i++){
    blob.fvals()[i] => X[frame][i];
  }
  <<<frame + " out of " + frames + " analysed">>>;
}
<<<"calculating">>>;

organize(X) @=> int new_order[];

<<<"playback">>>;

1 => mute.gain;
1 => w.record;
for(int i; i < new_order.size(); i++){
  ((new_order[i] * (chunk_size * 44.1))$int) => x.pos;
  chunk_size::ms => now;
}
0 => w.record;

fun int[] organize(float blobs[][]){
  int organized[0];
  for(int i; i < blobs.size(); i++){
    100.0 => float lowest;
    100 => int lowest_index;
    1 => int free;
    for(int j; j < blobs.size(); j++){
      if(i != j){
        if(blobs[j].size() != 1){
          blobs[i] @=> float main[];
          blobs[j] @=> float sub[];
          compare(main, sub) => float comp;
          if(comp < lowest){
            comp => lowest;
            j => lowest_index;
          }
        }
      }
    }
    <<<organized.size() + " out of " + blobs.size() + " finished">>>;
    organized << lowest_index;
    blobs[lowest_index].size(1);
  }
  return organized;
}

//thanks http://music.columbia.edu/~daniglesia/research/fftsplice/
fun float compare(float a[], float b[]){
  0 => float eval;
  for(int i; i < fft.size()/2; i++){
    Std.fabs(a[i] - b[i]) + eval => eval;
  }
  return eval;
}




