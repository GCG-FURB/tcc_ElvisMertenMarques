package br.com.furb.tagarela.view.activities;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.os.Bundle;
import android.widget.Toast;
import br.com.furb.tagarela.R;

import com.google.android.youtube.player.YouTubeBaseActivity;
import com.google.android.youtube.player.YouTubeInitializationResult;
import com.google.android.youtube.player.YouTubePlayer;
import com.google.android.youtube.player.YouTubePlayer.ErrorReason;
import com.google.android.youtube.player.YouTubePlayer.PlaybackEventListener;
import com.google.android.youtube.player.YouTubePlayer.PlayerStateChangeListener;
import com.google.android.youtube.player.YouTubePlayer.Provider;
import com.google.android.youtube.player.YouTubePlayerView;

public class VideoActivity extends YouTubeBaseActivity implements YouTubePlayer.OnInitializedListener {

	public static final String API_KEY = "AIzaSyAKdVQhChYEQd6N0GC3fXWUsNgy4GNHm5U";

	public String videoID;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		videoID = getYoutubeVideoId(getIntent().getExtras().getString("link"));
		/** attaching layout xml **/
		setContentView(R.layout.video_activity);

		/** Initializing YouTube player view **/
		YouTubePlayerView youTubePlayerView = (YouTubePlayerView) findViewById(R.id.youtube_player);
		youTubePlayerView.initialize(API_KEY, this);

	}

	public static String getYoutubeVideoId(String youtubeUrl) {
		String video_id = "";
		if(youtubeUrl.startsWith("www")){
			youtubeUrl = "http:\\"+youtubeUrl;
		}
		if (youtubeUrl != null && youtubeUrl.trim().length() > 0 && youtubeUrl.startsWith("http")) {

			String expression = "^.*((youtu.be\\/)|(v\\/)|(\\/u\\/w\\/)|(embed\\/)|(watch\\?))\\??v?=?([^#\\&\\?]*).*";
			CharSequence input = youtubeUrl;
			Pattern pattern = Pattern.compile(expression, Pattern.CASE_INSENSITIVE);
			Matcher matcher = pattern.matcher(input);
			if (matcher.matches()) {
				String groupIndex1 = matcher.group(7);
				if (groupIndex1 != null && groupIndex1.length() == 11)
					video_id = groupIndex1;
			}
		}
		return video_id;
	}

	@Override
	public void onInitializationFailure(Provider provider, YouTubeInitializationResult result) {
		Toast.makeText(this, "Failured to Initialize!", Toast.LENGTH_LONG).show();
	}

	@Override
	public void onInitializationSuccess(Provider provider, YouTubePlayer player, boolean wasRestored) {

		/** add listeners to YouTubePlayer instance **/
		player.setPlayerStateChangeListener(playerStateChangeListener);
		player.setPlaybackEventListener(playbackEventListener);

		/** Start buffering **/
		if (!wasRestored) {
			player.loadVideo(videoID);
		}
	}

	private PlaybackEventListener playbackEventListener = new PlaybackEventListener() {

		@Override
		public void onBuffering(boolean arg0) {

		}

		@Override
		public void onPaused() {

		}

		@Override
		public void onPlaying() {

		}

		@Override
		public void onSeekTo(int arg0) {

		}

		@Override
		public void onStopped() {

		}

	};

	private PlayerStateChangeListener playerStateChangeListener = new PlayerStateChangeListener() {

		@Override
		public void onAdStarted() {

		}

		@Override
		public void onError(ErrorReason arg0) {

		}

		@Override
		public void onLoaded(String arg0) {
			
		}

		@Override
		public void onLoading() {
		}

		@Override
		public void onVideoEnded() {

		}

		@Override
		public void onVideoStarted() {

		}
	};
}