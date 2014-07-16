package br.com.furb.tagarela.view.dialogs;

import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import br.com.furb.tagarela.R;
import br.com.furb.tagarela.interfaces.UserTypeListener;

public class TypeChooserDialog extends DialogFragment {
	 @Override
	    public View onCreateView(LayoutInflater inflater, ViewGroup container,
	            Bundle savedInstanceState) {
	        View view = inflater.inflate(R.layout.dialog_user_type_chooser, container);
	        view.findViewById(R.id.imgPatient).setOnClickListener(addUserPostListener(R.id.imgPatient));
	        view.findViewById(R.id.imgSpecialist).setOnClickListener(addUserPostListener(R.id.imgSpecialist));
	        view.findViewById(R.id.imgTutor).setOnClickListener(addUserPostListener(R.id.imgTutor));
	        getDialog().setTitle("Selecione o tipo de usuário");
	        return view;
	    }


	private OnClickListener addUserPostListener(final int id){
		return new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				UserTypeListener activity = (UserTypeListener) getActivity();
				if(id == R.id.imgPatient){
					activity.onUserReturnValue(0);
				}
				if(id == R.id.imgTutor){
					activity.onUserReturnValue(1);
				}
				if(id == R.id.imgSpecialist){
					activity.onUserReturnValue(2);
				}
				dismiss();
			}
		};
	}
}
