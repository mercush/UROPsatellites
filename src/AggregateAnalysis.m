function [r1, r2] = AggregateAnalysis
app = actxGetRunningServer('STK12.application');
root = app.Personality2;
r1 = RadarAnalysis(root);
r2 = EOIRAnalysis(root);