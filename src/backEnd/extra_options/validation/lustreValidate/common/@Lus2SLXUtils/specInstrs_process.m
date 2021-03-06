%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
% Notices:
%
% Copyright @ 2020 United States Government as represented by the 
% Administrator of the National Aeronautics and Space Administration.  All 
% Rights Reserved.
%
% Disclaimers
%
% No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY 
% WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING,
% BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL CONFORM 
% TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS 
% FOR A PARTICULAR PURPOSE, OR FREEDOM FROM INFRINGEMENT, ANY WARRANTY THAT
% THE SUBJECT SOFTWARE WILL BE ERROR FREE, OR ANY WARRANTY THAT 
% DOCUMENTATION, IF PROVIDED, WILL CONFORM TO THE SUBJECT SOFTWARE. THIS 
% AGREEMENT DOES NOT, IN ANY MANNER, CONSTITUTE AN ENDORSEMENT BY 
% GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT OF ANY RESULTS, RESULTING 
% DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY OTHER APPLICATIONS RESULTING 
% FROM USE OF THE SUBJECT SOFTWARE.  FURTHER, GOVERNMENT AGENCY DISCLAIMS 
% ALL WARRANTIES AND LIABILITIES REGARDING THIRD-PARTY SOFTWARE, IF PRESENT 
% IN THE ORIGINAL SOFTWARE, AND DISTRIBUTES IT "AS IS."
%
% Waiver and Indemnity:  RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS 
% AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, 
% AS WELL AS ANY PRIOR RECIPIENT.  IF RECIPIENT'S USE OF THE SUBJECT 
% SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES, EXPENSES OR 
% LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM PRODUCTS BASED 
% ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT SOFTWARE, RECIPIENT 
% SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED STATES GOVERNMENT, ITS 
% CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT, TO THE 
% EXTENT PERMITTED BY LAW.  RECIPIENT'S SOLE REMEDY FOR ANY SUCH MATTER 
% SHALL BE THE IMMEDIATE, UNILATERAL TERMINATION OF THIS AGREEMENT.
% 
% Notice: The accuracy and quality of the results of running CoCoSim 
% directly corresponds to the quality and accuracy of the model and the 
% requirements given as inputs to CoCoSim. If the models and requirements 
% are incorrectly captured or incorrectly input into CoCoSim, the results 
% cannot be relied upon to generate or error check software being developed. 
% Simply stated, the results of CoCoSim are only as good as
% the inputs given to CoCoSim.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function specInstrs_process(node_block_path, blk_spec, node_name)
    load_system(which('CoCoSimSpecification.slx'));
    assumes = blk_spec.assume;
    guarantees = blk_spec.guarantees;
    modes = blk_spec.modes;
    % add validator
    vPath = coco_nasa_utils.SLXUtils.makeBlockNameUnique(fullfile(node_block_path,'validator'));
    vHandle = add_block('CoCoSimSpecification/contract/validator', ...
        vPath, ...
        'MakeNameUnique', 'on', ...
        'assumePorts', num2str(length(assumes)), ...
        'guaranteePorts', num2str(length(guarantees)), ...
        'modePorts', num2str(length(modes)));
    
    % remove connected blocks to validator that are added by its callback
    coco_nasa_utils.SLXUtils.removeBlocksLinkedToMe(vHandle, false);
    %make sure all porthandles are -1
    vPortConnectivity = get_param(vHandle, 'PortConnectivity');
    srcBlocks = {vPortConnectivity.SrcBlock};
    srcBlocks = srcBlocks(~cellfun(@isempty, srcBlocks));
    if any(cellfun(@(x) x~=-1, srcBlocks))
        % there is a connection that is not removed
    end
    % add validator output
    output_path = coco_nasa_utils.SLXUtils.makeBlockNameUnique(fullfile(node_block_path,'valid'));
    outHandle = add_block('simulink/Ports & Subsystems/Out1',...
        output_path);
    SrcBlkH = get_param(vHandle,'PortHandles');
    DstBlkH = get_param(outHandle, 'PortHandles');
    add_line(node_block_path, SrcBlkH.Outport(1), DstBlkH.Inport(1), 'autorouting', 'on');
    
    % link assumptions and guarantees and modes
    vport = 1;
    for i=1:length(assumes)
        % add assume block
        assume_name = 'assume';
        if isfield(assumes(i), 'name') && ~isempty(assumes(i).name)
            assume_name = assumes(i).name;
        end
        assumePath = coco_nasa_utils.SLXUtils.makeBlockNameUnique(fullfile(node_block_path, assume_name));
        aHandle = add_block('CoCoSimSpecification/assume', ...
            assumePath, ...
            'MakeNameUnique', 'on');
        assumePath = fullfile(node_block_path, get_param(aHandle, 'Name'));
        process_assumeGuarantee(node_block_path, assumePath, assumes(i), vHandle, vport, node_name);
        vport = vport + 1;
    end
    for i=1:length(guarantees)
        % add guarantee block
        g_name = 'assume';
        if isfield(guarantees(i), 'name') && ~isempty(guarantees(i).name)
            g_name = guarantees(i).name;
        end
        gPath = coco_nasa_utils.SLXUtils.makeBlockNameUnique(fullfile(node_block_path,g_name));
        gHandle = add_block('CoCoSimSpecification/guarantee', ...
            gPath, ...
            'MakeNameUnique', 'on');
        gPath = fullfile(node_block_path, get_param(gHandle, 'Name'));
        process_assumeGuarantee(node_block_path, gPath, guarantees(i), vHandle, vport, node_name);
        vport = vport + 1;
    end
    for i=1:length(modes)
        process_mode(node_block_path, modes(i), vHandle, vport, node_name);
        vport = vport + 1;
    end
end

function process_assumeGuarantee(node_block_path, gPath, gStruct, vHandle, vPortNumber, node_name)
    % add inport outport inside
    createInportOutport(gPath);
    
    % add outside connection
    rhs_name = coco_nasa_utils.SLXUtils.adapt_block_name(gStruct.qfexpr.value, node_name);
    rhs_path = coco_nasa_utils.SLXUtils.makeBlockNameUnique(strcat(gPath,'_rhs'));
    add_block('simulink/Signal Routing/From',...
        rhs_path,...
        'GotoTag',rhs_name,...
        'TagVisibility', 'local');
    SrcBlkH = get_param(rhs_path,'PortHandles');
    DstBlkH = get_param(gPath, 'PortHandles');
    add_line(node_block_path, SrcBlkH.Outport(1), DstBlkH.Inport(1), 'autorouting', 'on');
    
    %     add link to validator block
    SrcBlkH = get_param(gPath,'PortHandles');
    DstBlkH = get_param(vHandle, 'PortHandles');
    add_line(node_block_path, SrcBlkH.Outport(1), DstBlkH.Inport(vPortNumber), 'autorouting', 'on');
end


function process_mode(node_block_path, mode, vHandle, vPortNumber, node_name)
    mode_id = mode.mode_id;
    requires = mode.require;
    ensures = mode.ensure;
    
    % add mode block
    mPath = coco_nasa_utils.SLXUtils.makeBlockNameUnique(fullfile(node_block_path, mode_id));
    mHandle = add_block('CoCoSimSpecification/mode', ...
        mPath, ...
        'MakeNameUnique', 'on');
    
    %add link to validator block
    SrcBlkH = get_param(mHandle,'PortHandles');
    DstBlkH = get_param(vHandle, 'PortHandles');
    add_line(node_block_path, SrcBlkH.Outport(1), DstBlkH.Inport(vPortNumber), 'autorouting', 'on');
    
    % add require block
    rPath = coco_nasa_utils.SLXUtils.makeBlockNameUnique(fullfile(node_block_path, ...
        strcat(mode_id, '_require')));
    rHandle = add_block('CoCoSimSpecification/require', ...
        rPath, ...
        'MakeNameUnique', 'on');
    rPath = fullfile(node_block_path, get_param(rHandle, 'Name'));
    createInportOutport(rPath);
    %add link to mode block
    SrcBlkH = get_param(rHandle,'PortHandles');
    DstBlkH = get_param(mHandle, 'PortHandles');
    add_line(node_block_path, SrcBlkH.Outport(1), DstBlkH.Inport(1), 'autorouting', 'on');
    
    % add ensure block
    ePath = coco_nasa_utils.SLXUtils.makeBlockNameUnique(fullfile(node_block_path, ...
        strcat(mode_id, '_ensure')));
    eHandle = add_block('CoCoSimSpecification/ensure', ...
        ePath, ...
        'MakeNameUnique', 'on');
    ePath = fullfile(node_block_path, get_param(eHandle, 'Name'));
    createInportOutport(ePath);
    %add link to mode block
    SrcBlkH = get_param(eHandle,'PortHandles');
    DstBlkH = get_param(mHandle, 'PortHandles');
    add_line(node_block_path, SrcBlkH.Outport(1), DstBlkH.Inport(2), 'autorouting', 'on');
    
    % add require conditions
    addRequireEnsureConditions(node_block_path, node_name, rPath, rHandle, requires);
    
    % add ensure conditions
    addRequireEnsureConditions(node_block_path, node_name, ePath, eHandle, ensures);
    
end
function addRequireEnsureConditions(node_block_path, node_name, rPath, rHandle, requires)
    if isempty(requires)
        % require true;
        cst_path = coco_nasa_utils.SLXUtils.makeBlockNameUnique(strcat(rPath, '_true'));
        cHandle = add_block('simulink/Commonly Used Blocks/Constant',...
            cst_path,...
            'MakeNameUnique', 'on',...
            'Value','true',...
            'OutDataTypeStr','boolean');
        %add link to mode block
        SrcBlkH = get_param(cHandle,'PortHandles');
        DstBlkH = get_param(rHandle, 'PortHandles');
        add_line(node_block_path, SrcBlkH.Outport(1), DstBlkH.Inport(1), 'autorouting', 'on');
    else
        op_path = coco_nasa_utils.SLXUtils.makeBlockNameUnique(strcat(rPath, '_cond'));
        
        opHandle = add_block('simulink/Logic and Bit Operations/Logical Operator',...
            op_path, ...
            'MakeNameUnique', 'on',...
            'Operator', 'AND',...
            'Inputs', num2str(length(requires)));
        
        %add link to mode block
        SrcBlkH = get_param(opHandle,'PortHandles');
        DstBlkH = get_param(rHandle, 'PortHandles');
        add_line(node_block_path, SrcBlkH.Outport(1), DstBlkH.Inport(1), 'autorouting', 'on');
        
        %add all requires
        for i=1:length(requires)
            rhs_name = coco_nasa_utils.SLXUtils.adapt_block_name(requires(i).qfexpr.value, node_name);
            if isfield(requires(i), 'name')
                rhs_path = coco_nasa_utils.SLXUtils.makeBlockNameUnique(strcat(op_path,requires(i).name));
            else
                rhs_path = coco_nasa_utils.SLXUtils.makeBlockNameUnique(strcat(op_path,'_rhs'));
            end
            rhsHandle = add_block('simulink/Signal Routing/From',...
                rhs_path,...
                'MakeNameUnique', 'on', ...
                'GotoTag',rhs_name,...
                'TagVisibility', 'local');
            SrcBlkH = get_param(rhsHandle,'PortHandles');
            DstBlkH = get_param(opHandle, 'PortHandles');
            add_line(node_block_path, SrcBlkH.Outport(1), DstBlkH.Inport(i), 'autorouting', 'on');
        end
    end
end
function createInportOutport(rPath)
    % check if there is an output
    outport = find_system(rPath, 'LookUnderMasks', 'all', 'BlockType', 'Outport');
    if isempty(outport)
        outportPath = fullfile(rPath, 'Out1');
        add_block('simulink/Ports & Subsystems/Out1', outportPath);
    else
        if length(outport) > 1
            for i=2:length(outport), delete_block(outport{i});end
        end
        outportPath = outport{1};
    end
    % add inport
    inport =  find_system(rPath, 'LookUnderMasks', 'all', 'BlockType', 'Inport');
    if isempty(inport)
        inportPath = fullfile(rPath, 'In1');
        add_block('simulink/Ports & Subsystems/In1', inportPath);
    else
        if length(inport) > 1
            for i=2:length(inport), delete_block(inport{i});end
        end
        inportPath = inport{1};
    end
    % add link between inport and outport inside require
    SrcBlkH = get_param(inportPath,'PortHandles');
    DstBlkH = get_param(outportPath, 'PortHandles');
    add_line(rPath, SrcBlkH.Outport(1), DstBlkH.Inport(1), 'autorouting', 'on');
end
