function save_result(modelbase, path, model_name, rule_name)
  output.model = model_name;
  output.rule = rule_name;

  data.AC = struct_from_names_and_values(modelbase.AUTendo_names, @(i) modelbase.AUTR(i,:));
  data.VAR = struct_from_names_and_values(modelbase.VARendo_names, @(i) modelbase.VAR(i,i));

  for p = 1:size(modelbase.innos, 1)
    % 0 if shock unavailable
    if(modelbase.pos_shock(p)) == 0
      continue;
    end

    inno = deblank(modelbase.innos(p, :));
    data.IRF.(inno) = struct_from_names_and_values(modelbase.IRFendo_names, @(i) modelbase.IRF(i,:,p));
  end

  output.data = data;

  [folder] = fileparts(path);
  mkdir(folder);

  opts.FileName = path;

  savejson('', output, opts);
end
