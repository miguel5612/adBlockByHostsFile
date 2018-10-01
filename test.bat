private iNumProcesses; 
private void RunApps()
{
    iNumProcesses = dataGridView1.Rows.Count;
    string sPath = .exe application path    
    for (int i = 0; i < iNumProcesses; i++)
    {   
        string sArgs = dataGridView1.Rows[i]["Arguments"].ToString();
        ExecuteProgram(sPath, sArgs);
    }
}
private void ExecuteProgram(string sProcessName, string sArgs) 
{
    using (cmd = new Process())
    {
        cmd.StartInfo.FileName = sProcessName;
        cmd.StartInfo.Arguments = sArgs;
        cmd.StartInfo.UseShellExecute = false;
        cmd.StartInfo.CreateNoWindow = true;
        cmd.StartInfo.ErrorDialog = true;
        cmd.StartInfo.RedirectStandardOutput = true;
        cmd.StartInfo.RedirectStandardError = true;
        cmd.OutputDataReceived += new DataReceivedEventHandler(SortOutputHandler);
        cmd.ErrorDataReceived += new DataReceivedEventHandler(SortOutputHandler);
        cmd.Start();
        cmd.BeginOutputReadLine();
        while (!cmd.HasExited) { Application.DoEvents(); }
    }        
}
private void SortOutputHandler(object sender, DataReceivedEventArgs e)
{
    Trace.WriteLine(e.Data);
    this.BeginInvoke(new MethodInvoker(() =>
    {
        if (e.Data == "Start") { do something... }
        else if (e.Data == "Finish") { do something... }
        else if (e.Data == "End")   { do something... }
        else
        {
            // .exe application output numbers 1 through 100
            toolStripProgressBar1.Value += Math.Round(Convert.ToInt32(e.Data)/iNumProcesses,0);
        }
    }));
}